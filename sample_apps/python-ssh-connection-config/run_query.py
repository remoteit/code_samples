#!/usr/bin/env python3

import argparse
from base64 import b64decode
import configparser
import pathlib
import requests
from requests_http_signature import HTTPSignatureAuth
import yaml

DEFAULT_SECTION = "default"

# TODO construct schemas using graphene
QUERY_GET_ALL_DEVICES = "query { login { id email devices { items { id name state}}}}"


def run_query(
    credentials: configparser.ConfigParser,
    *,
    query: str,
    section: str = DEFAULT_SECTION,
) -> None:
    # Modified from https://docs.remote.it/developer-tools/authentication#api-request-signing
    key_id = credentials[section].get("R3_ACCESS_KEY_ID")
    key_secret_id = credentials[section].get("R3_SECRET_ACCESS_KEY")

    body = {"query": query}
    host = "api.remote.it"
    url_path = "/graphql/v1"
    content_type_header = "application/json"
    content_length_header = str(len(body))

    headers = {
        "host": host,
        "path": url_path,
        "content-type": content_type_header,
        "content-length": content_length_header,
    }

    # This should work with 0.7.1 but doesn't, likely due to remote.it using an outdated draft standard.
    # This seems to have changed behavior in 0.3.0.
    # response = requests.post(
    #     "https://" + host + url_path,
    #     json=body,
    #     auth=HTTPSignatureAuth(
    #         # todo import algorithms from requests_http_signature
    #         signature_algorithm=algorithms.HMAC_SHA256,
    #         key=b64decode(key_secret_id),
    #         key_id=key_id,
    #         covered_component_ids=[
    #             "@request-target",
    #             "host",
    #             "@date",
    #             "content-type",
    #             "content-length"
    #         ]
    #         # headers=[
    #         #     "(request-target)",
    #         #     "host",
    #         #     "date",
    #         #     "content-type",
    #         #     "content-length",
    #         # ],
    #     ),
    #     headers=headers,
    # )

    response = requests.post(
        "https://" + host + url_path,
        json=body,
        auth=HTTPSignatureAuth(
            algorithm="hmac-sha256",
            key=b64decode(key_secret_id),
            key_id=key_id,
            headers=[
                "(request-target)",
                "host",
                "date",
                "content-type",
                "content-length",
            ],
        ),
        headers=headers,
    )

    if response.status_code == 200:
        print(yaml.dump(response.json()))
    else:
        print(response.status_code)
        print(response.text)


def read_config() -> configparser.ConfigParser:
    config_path = pathlib.Path.home() / ".remoteit" / "credentials"
    try:
        assert config_path.exists()
    except AssertionError as e:
        print(f"Not found: {config_path}")
        raise e
    cfg_parser = configparser.ConfigParser()
    cfg_parser.read(config_path)

    return cfg_parser


def validate_credentials(
    credentials: configparser.ConfigParser, *, section=DEFAULT_SECTION
) -> None:
    sections = credentials.sections()
    # TODO support selecting a section other than default
    assert section in sections
    cred_section = credentials[section]
    assert "R3_ACCESS_KEY_ID" in cred_section
    assert "R3_SECRET_ACCESS_KEY" in cred_section


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--section",
        type=str,
        required=False,
        help="Section of credentials to use for auth",
        default=DEFAULT_SECTION,
    )
    args = parser.parse_args()
    creds = read_config()
    validate_credentials(creds, section=args.section)
    run_query(creds, query=QUERY_GET_ALL_DEVICES, section=args.section)


if __name__ == "__main__":
    main()
