#!/usr/bin/env python3
"""Create a JHE patient + invitation, redeem it, print access token.

Usage:
  python3 scripts/jhe_create_invite.py

For an invitation link only (existing patient, no redeem):
  python3 scripts/jhe_invite_existing.py --patient-id 40001
"""

from __future__ import annotations

import base64
import hashlib
import json
import re
import secrets
import sys
import urllib.error
import urllib.parse
import urllib.request
from http.cookiejar import CookieJar

# =============================================================================
# CONFIG — change these
# =============================================================================

BASE_URL = "https://jhe.fly.dev"

# Practitioner used to create the patient / invitation (seeded staging users)
PRACTITIONER_EMAIL = "manager_mary@example.com"
PRACTITIONER_PASSWORD = "REDACTED"

# OAuth client for practitioner login (JHE Admin UI on staging)
OAUTH_CLIENT_ID = "uxxQf9p5J4GCv2jzdXtOOKcYXAc18In0hJzDCLc1"
OAUTH_REDIRECT_URI = f"{BASE_URL}/auth/callback"

# Org / study / invitation client (DB primary keys from /api/v1/...)
ORGANIZATION_ID = 20003  # Lifespan Lab
# Must be in the same org as the patient. JHE rejects cross-org enrollment
# (e.g. 30003 Cardiology Division will 500 for Lifespan Lab patients).
STUDY_ID = 30007  # test study — glucose, BP, steps, sleep
# STUDY_ID = 30001  # Lifespan Study on BP & HR (now includes blood glucose)
INVITATION_CLIENT_ID = 1  # CareX (Application.id, not clientId string)

# New patient — email must be unused for a *new* user.
# If this email already has a patient, script reuses them (see REUSE_EXISTING_BY_EMAIL).
PATIENT_EMAIL = "test.patient+88@example.com"
PATIENT_GIVEN = "Test"
PATIENT_FAMILY = "Patient"
PATIENT_BIRTH_DATE = "1990-01-01"
PATIENT_PHONE = "555-0100"
# Optional external identifiers; set to [] to skip
PATIENT_IDENTIFIERS = [
    # {"system": "https://openwearables.io/ns/patient-id", "value": "abc123"},
]

# Set to an existing patient id to skip create (still makes a fresh invitation)
EXISTING_PATIENT_ID = None  # e.g. 40001

# If create fails because email/user already exists, reuse that patient and continue
REUSE_EXISTING_BY_EMAIL = True

# =============================================================================


def _print_step(title: str, status: int | None = None, body: object = None) -> None:
    print("\n" + "=" * 72)
    print(title if status is None else f"{title}  [HTTP {status}]")
    print("=" * 72)
    if body is None:
        return
    if isinstance(body, (dict, list)):
        print(json.dumps(body, indent=2, ensure_ascii=False))
    else:
        text = str(body)
        print(text if len(text) < 4000 else text[:4000] + "\n... [truncated]")


def _request(
    method: str,
    url: str,
    *,
    data: dict | str | None = None,
    headers: dict | None = None,
    form: dict | None = None,
    opener: urllib.request.OpenerDirector | None = None,
) -> tuple[int, str, dict[str, str]]:
    hdrs = dict(headers or {})
    body: bytes | None = None

    if form is not None:
        body = urllib.parse.urlencode(form).encode()
        hdrs.setdefault("Content-Type", "application/x-www-form-urlencoded")
    elif data is not None:
        if isinstance(data, dict):
            body = json.dumps(data).encode()
            hdrs.setdefault("Content-Type", "application/json")
        else:
            body = data.encode() if isinstance(data, str) else data

    req = urllib.request.Request(url, data=body, headers=hdrs, method=method)
    open_fn = opener.open if opener else urllib.request.urlopen
    try:
        with open_fn(req) as resp:
            raw = resp.read().decode()
            return resp.status, raw, {k.lower(): v for k, v in resp.headers.items()}
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        return e.code, raw, {k.lower(): v for k, v in e.headers.items()}


def _parse_json(raw: str) -> object:
    try:
        return json.loads(raw) if raw else None
    except json.JSONDecodeError:
        return raw


def _pkce() -> tuple[str, str]:
    verifier = base64.urlsafe_b64encode(secrets.token_bytes(32)).rstrip(b"=").decode()
    challenge = (
        base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest())
        .rstrip(b"=")
        .decode()
    )
    return verifier, challenge


def login_practitioner() -> str:
    jar = CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

    status, html, _ = _request("GET", f"{BASE_URL}/accounts/login/", opener=opener)
    _print_step("GET /accounts/login/", status, html[:500] if isinstance(html, str) else html)
    csrf_match = re.search(
        r'name=["\']csrfmiddlewaretoken["\'] value=["\']([^"\']+)', html
    )
    if not csrf_match:
        raise RuntimeError("CSRF token not found on login page")
    csrf = csrf_match.group(1)

    status, raw, headers = _request(
        "POST",
        f"{BASE_URL}/accounts/login/",
        form={
            "csrfmiddlewaretoken": csrf,
            "username": PRACTITIONER_EMAIL,
            "password": PRACTITIONER_PASSWORD,
        },
        headers={
            "Referer": f"{BASE_URL}/accounts/login/",
            "Origin": BASE_URL,
        },
        opener=opener,
    )
    # urllib follows redirects by default for 302 on POST in some cases; print anyway
    _print_step("POST /accounts/login/", status, raw[:500] if raw else headers)

    if not any(c.name == "sessionid" for c in jar):
        raise RuntimeError("Login failed — no session cookie (check email/password)")

    verifier, challenge = _pkce()
    state = secrets.token_urlsafe(16)
    auth_qs = urllib.parse.urlencode(
        {
            "response_type": "code",
            "client_id": OAUTH_CLIENT_ID,
            "redirect_uri": OAUTH_REDIRECT_URI,
            "scope": "openid email",
            "state": state,
            "code_challenge": challenge,
            "code_challenge_method": "S256",
        }
    )
    auth_url = f"{BASE_URL}/o/authorize/?{auth_qs}"

    # Don't follow redirect to callback — we need the ?code=
    class NoRedirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            return None

    auth_opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(jar), NoRedirect
    )
    status, raw, headers = _request("GET", auth_url, opener=auth_opener)
    location = headers.get("location", "")
    _print_step("GET /o/authorize/", status, {"location": location, "body": raw[:300]})

    code = urllib.parse.parse_qs(urllib.parse.urlparse(location).query).get("code", [None])[0]
    if not code:
        raise RuntimeError(f"No authorization code in redirect: {location!r}")

    status, raw, _ = _request(
        "POST",
        f"{BASE_URL}/o/token/",
        form={
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": OAUTH_REDIRECT_URI,
            "client_id": OAUTH_CLIENT_ID,
            "code_verifier": verifier,
        },
    )
    token_body = _parse_json(raw)
    _print_step("POST /o/token/ (practitioner)", status, token_body)
    if not isinstance(token_body, dict) or "access_token" not in token_body:
        raise RuntimeError("Failed to get practitioner access token")
    return token_body["access_token"]


def api(
    method: str,
    path: str,
    access_token: str | None = None,
    data: dict | None = None,
    form: dict | None = None,
    *,
    raise_on_error: bool = True,
) -> tuple[int, object]:
    headers = {}
    if access_token:
        headers["Authorization"] = f"Bearer {access_token}"
    status, raw, _ = _request(
        method,
        f"{BASE_URL}{path}",
        data=data,
        form=form,
        headers=headers,
    )
    body = _parse_json(raw)
    _print_step(f"{method} {path}", status, body)
    if raise_on_error and status >= 400:
        raise RuntimeError(f"Request failed: {method} {path} -> {status}")
    return status, body


def find_patient_id_by_email(access_token: str, email: str) -> int | None:
    """Look up existing user/patient by email via Admin API."""
    status, body = api(
        "GET",
        f"/api/v1/users/search_by_email?{urllib.parse.urlencode({'email': email})}",
        access_token,
        raise_on_error=False,
    )
    if status >= 400 or not isinstance(body, dict):
        return None
    patient = body.get("patient")
    if isinstance(patient, dict) and patient.get("id") is not None:
        return int(patient["id"])
    # Fallback: search patients list for matching telecomEmail
    status, listing = api(
        "GET",
        f"/api/v1/patients?organization_id={ORGANIZATION_ID}",
        access_token,
        raise_on_error=False,
    )
    if status >= 400 or not isinstance(listing, dict):
        return None
    email_l = email.lower()
    for p in listing.get("results") or []:
        if str(p.get("telecomEmail") or "").lower() == email_l:
            return int(p["id"])
    return None


def resolve_patient_id(practitioner_token: str) -> int:
    if EXISTING_PATIENT_ID:
        print(f"\nUsing EXISTING_PATIENT_ID={EXISTING_PATIENT_ID}")
        return int(EXISTING_PATIENT_ID)

    existing = find_patient_id_by_email(practitioner_token, PATIENT_EMAIL)
    if existing is not None and REUSE_EXISTING_BY_EMAIL:
        print(
            f"\nPatient already exists for {PATIENT_EMAIL!r} "
            f"(id={existing}) — reusing and issuing a new invitation."
        )
        return existing

    payload = {
        "organization_id": ORGANIZATION_ID,
        "name_family": PATIENT_FAMILY,
        "name_given": PATIENT_GIVEN,
        "birth_date": PATIENT_BIRTH_DATE,
        "telecom_phone": PATIENT_PHONE,
        "telecom_email": PATIENT_EMAIL,
    }
    if PATIENT_IDENTIFIERS:
        payload["identifiers"] = PATIENT_IDENTIFIERS

    status, patient = api(
        "POST",
        "/api/v1/patients",
        practitioner_token,
        data=payload,
        raise_on_error=False,
    )
    if status < 400 and isinstance(patient, dict) and "id" in patient:
        return int(patient["id"])

    # Typical case: same email already has a JheUser+Patient → IntegrityError
    if REUSE_EXISTING_BY_EMAIL:
        reused = find_patient_id_by_email(practitioner_token, PATIENT_EMAIL)
        if reused is not None:
            print(
                f"\nCreate conflict for {PATIENT_EMAIL!r} — "
                f"reusing existing patient id={reused}."
            )
            return reused

    raise RuntimeError(
        "Could not create patient. Usually means this email (or an identifier) "
        f"already exists. Change PATIENT_EMAIL (currently {PATIENT_EMAIL!r}) "
        "or set EXISTING_PATIENT_ID / REUSE_EXISTING_BY_EMAIL."
    )


def enroll_in_study(
    practitioner_token: str, patient_id: int, study_id: int | None
) -> None:
    if study_id is None:
        return
    status, _ = api(
        "POST",
        f"/api/v1/studies/{study_id}/patients",
        practitioner_token,
        data={"patient_ids": [patient_id]},
        raise_on_error=False,
    )
    # 4xx: typically already enrolled. 5xx: often patient/study org mismatch.
    if status >= 500:
        raise RuntimeError(
            f"Study enrollment failed ({status}). Patient and study must be "
            f"in the same organization (org={ORGANIZATION_ID}, study={study_id})."
        )
    if status >= 400:
        print(f"\nStudy enroll returned {status} (already enrolled?); continuing.")


def main() -> int:
    print(f"BASE_URL={BASE_URL}")
    print(f"practitioner={PRACTITIONER_EMAIL}")
    print(f"patient_email={PATIENT_EMAIL}")
    print(f"study_id={STUDY_ID}")

    practitioner_token = login_practitioner()
    patient_id = resolve_patient_id(practitioner_token)
    enroll_in_study(practitioner_token, patient_id, STUDY_ID)

    _, invitation = api(
        "POST",
        "/api/v1/invitation",
        practitioner_token,
        data={
            "patient_id": patient_id,
            "client_id": INVITATION_CLIENT_ID,
            "send_email": False,
        },
    )
    assert isinstance(invitation, dict)
    invite_token = invitation.get("token")
    if not invite_token:
        raise RuntimeError("invitation.token missing in response")

    _, redeem = api("POST", f"/api/v1/invitation/{invite_token}")
    assert isinstance(redeem, dict)
    grant = redeem["grant"]
    code_verifier = (
        base64.urlsafe_b64encode(invite_token.encode()).rstrip(b"=").decode()
    )

    _, token_body = api(
        "POST",
        "/o/token/",
        form={
            "grant_type": grant["grant_type"],
            "code": grant["code"],
            "redirect_uri": grant["redirect_uri"],
            "client_id": grant["client_id"],
            "code_verifier": code_verifier,
        },
    )
    assert isinstance(token_body, dict)

    _, profile = api(
        "GET",
        "/api/v1/users/profile",
        access_token=token_body["access_token"],
    )

    print("\n" + "#" * 72)
    print("SUMMARY")
    print("#" * 72)
    print(f"patient_id:        {patient_id}")
    print(f"study_id:          {STUDY_ID}")
    print(f"invitation_token:  {invite_token}")
    print(f"invitation_link:   {invitation.get('invitationLink') or invitation.get('invitation_link')}")
    print(f"access_token:      {token_body.get('access_token')}")
    print(f"refresh_token:     {token_body.get('refresh_token')}")
    print(f"expires_in:        {token_body.get('expires_in')}")
    if isinstance(profile, dict):
        print(f"profile.user_id:   {profile.get('id')}")
        patient = profile.get("patient") or {}
        print(f"profile.patient_id:{patient.get('id')}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"\nERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
