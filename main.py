import asyncio
from datetime import datetime

from settings import POLL_INTERVAL
from storage import load_config, prompt_config, load_last_id, save_last_id
from parser import TgParser


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


async def main():
    config = load_config()
    if not config:
        config = prompt_config()

    parser = TgParser(config['api_id'], config['api_hash'])
    await parser.start(config['phone'])
    await parser.set_chat(config['chat_username'])

    last_id = load_last_id()

    print(f"\nПарсинг чата {config['chat_username']} запущен")
    print(f"Интервал: 15 мин. Последний ID: {last_id or 'нет'}")
    print("Ctrl+C для остановки\n")

    while True:
        try:
            messages = await parser.get_new_messages(min_id=last_id)

            if messages:
                for msg in reversed(messages):
                    print(await format_message(msg))
                last_id = max(m.id for m in messages)
                save_last_id(last_id)
            else:
                ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                print(f"[{ts}] Новых сообщений нет")

        except Exception as e:
            ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            print(f"[{ts}] Ошибка: {e}")

        await asyncio.sleep(POLL_INTERVAL)


if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nПарсинг остановлен")
