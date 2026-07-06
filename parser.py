from telethon import TelegramClient
from settings import SESSION_NAME, LIMIT, WAIT_TIME


class TgParser:
    def __init__(self, api_id, api_hash):
        self.client = TelegramClient(SESSION_NAME, api_id, api_hash)
        self.chat = None

    async def start(self, phone):
        await self.client.start(phone=phone)

    async def set_chat(self, username):
        self.chat = await self.client.get_entity(username)

    async def get_new_messages(self, min_id=0, limit=LIMIT):
        return await self.client.get_messages(
            self.chat, min_id=min_id, limit=limit, wait_time=WAIT_TIME
        )

    async def stop(self):
        await self.client.disconnect()
