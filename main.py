import asyncio
import json
import os
from datetime import datetime
from telethon import TelegramClient

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


def load_last_id():
    try:
        with open(LAST_ID_FILE) as f:
            return int(f.read().strip())
    except (FileNotFoundError, ValueError):
        return 0


def save_last_id(msg_id):
    with open(LAST_ID_FILE, 'w') as f:
        f.write(str(msg_id))


async def main():
    config = load_config()
    if not config:
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

    client = TelegramClient('session', config['api_id'], config['api_hash'])
    await client.start(phone=config['phone'])

    chat = await client.get_entity(config['chat_username'])
    last_id = load_last_id()

    print(f"\nПарсинг чата {config['chat_username']} запущен")
    print(f"Интервал: 15 мин. Последний ID: {last_id or 'нет'}")
    print("Ctrl+C для остановки\n")

    while True:
        try:
            messages = await client.get_messages(chat, min_id=last_id, limit=100, wait_time=0)

            if messages:
                for msg in reversed(messages):
                    sender = msg.sender_id
                    try:
                        s = await msg.get_sender()
                        if s:
                            sender = s.first_name or s.username or str(s.id)
                    except Exception:
                        pass

                    text = msg.text or '(медиа/стикер)'
                    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    print(f"[{ts}] {sender}: {text}")

                last_id = max(m.id for m in messages)
                save_last_id(last_id)
            else:
                ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                print(f"[{ts}] Новых сообщений нет")

        except Exception as e:
            ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            print(f"[{ts}] Ошибка: {e}")

        await asyncio.sleep(15 * 60)


if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nПарсинг остановлен")
