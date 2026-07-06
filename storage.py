import json
import os

CONFIG_FILE = 'config.json'
LAST_ID_FILE = 'last_id.txt'


def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE) as f:
            return json.load(f)
    return None


def save_config(config):
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)


def prompt_config():
    print("=== Первый запуск ===")
    print("API ID и API Hash: https://my.telegram.org")
    api_id = int(input("API ID: ").strip())
    api_hash = input("API Hash: ").strip()
    phone = input("Номер телефона (с кодом, напр. +79123456789): ").strip()
    chat_username = input("Username чата (с @, напр. @durov): ").strip()
    config = {
        'api_id': api_id,
        'api_hash': api_hash,
        'phone': phone,
        'chat_username': chat_username
    }
    save_config(config)
    return config


def load_last_id():
    try:
        with open(LAST_ID_FILE) as f:
            return int(f.read().strip())
    except (FileNotFoundError, ValueError):
        return 0


def save_last_id(msg_id):
    with open(LAST_ID_FILE, 'w') as f:
        f.write(str(msg_id))
