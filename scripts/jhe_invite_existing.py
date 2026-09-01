#!/usr/bin/env python3
"""Create a JHE invitation link for an existing patient (does not redeem it).

Usage:
  python3 scripts/jhe_invite_existing.py --patient-id 40001
  python3 scripts/jhe_invite_existing.py 40001
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import jhe_create_invite as jhe  # noqa: E402


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create an invitation link for an existing JHE patient."
    )
    parser.add_argument(
        "patient_id",
        nargs="?",
        type=int,
        help="Existing patient id (DB primary key)",
    )
    parser.add_argument(
        "--patient-id",
        dest="patient_id_flag",
        type=int,
        help="Existing patient id (same as positional)",
    )
    parser.add_argument(
        "--no-enroll",
        action="store_true",
        help="Skip posting the patient into STUDY_ID",
    )
    args = parser.parse_args()
    patient_id = args.patient_id_flag if args.patient_id_flag is not None else args.patient_id
    if patient_id is None:
        parser.error("patient id is required (positional or --patient-id)")
    args.patient_id = patient_id
    return args


def main() -> int:
    args = parse_args()
    patient_id = args.patient_id

    print(f"BASE_URL={jhe.BASE_URL}")
    print(f"practitioner={jhe.PRACTITIONER_EMAIL}")
    print(f"patient_id={patient_id}")

    practitioner_token = jhe.login_practitioner()

    if not args.no_enroll:
        jhe.enroll_in_study(practitioner_token, patient_id, jhe.STUDY_ID)

    _, invitation = jhe.api(
        "POST",
        "/api/v1/invitation",
        practitioner_token,
        data={
            "patient_id": patient_id,
            "client_id": jhe.INVITATION_CLIENT_ID,
            "send_email": False,
        },
    )
    assert isinstance(invitation, dict)
    invite_token = invitation.get("token")
    invite_link = invitation.get("invitationLink") or invitation.get("invitation_link")
    if not invite_token:
        raise RuntimeError("invitation.token missing in response")

    print("\n" + "#" * 72)
    print("SUMMARY")
    print("#" * 72)
    print(f"patient_id:        {patient_id}")
    print(f"study_id:          {jhe.STUDY_ID}")
    print(f"invitation_token:  {invite_token}")
    print(f"invitation_link:   {invite_link}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"\nERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
