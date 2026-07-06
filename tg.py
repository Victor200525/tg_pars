from datetime import datetime
from telethon import TelegramClient


def create_client(api_id, api_hash):
    return TelegramClient('session', api_id, api_hash)


async def start_client(client, phone):
    await client.start(phone=phone)


async def get_chat(client, username):
    return await client.get_entity(username)


async def format_message(msg):
    sender = msg.sender_id
    try:
        s = await msg.get_sender()
        if s:
            sender = s.first_name or s.username or str(s.id)
    except Exception:
        pass

    text = msg.text or '(медиа/стикер)'
    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return f"[{ts}] {sender}: {text}"
