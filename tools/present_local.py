"""Serve somente build/web no próprio Windows e abre a moldura mobile."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import URLError
from urllib.request import urlopen
import webbrowser

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build' / 'web'
BASE_URL = 'http://127.0.0.1:8080/'
PRESENTATION_URL = BASE_URL + '?celular=1'

class LocalPresentationServer(ThreadingHTTPServer):
    allow_reuse_address = False

def reuse_existing():
    try:
        with urlopen(BASE_URL, timeout=3) as response:
            recognized = b'<title>SoundWave</title>' in response.read(100_000)
    except (URLError, OSError):
        return False
    if not recognized:
        return False
    print('Usando o SoundWave que já está aberto neste computador.')
    print(PRESENTATION_URL)
    webbrowser.open(PRESENTATION_URL)
    return True

def main():
    if not (BUILD / 'index.html').is_file() or not (BUILD / 'main.dart.js').is_file():
        print('Build não encontrado. Consulte o README para compilar o SoundWave.')
        return 1
    if reuse_existing():
        return 0
    try:
        server = LocalPresentationServer(('127.0.0.1', 8080), partial(SimpleHTTPRequestHandler, directory=str(BUILD)))
    except OSError:
        if reuse_existing():
            return 0
        print('A porta 8080 já está ocupada por outro serviço. Nenhum processo foi encerrado.')
        return 1
    with server:
        print('Mantenha esta janela aberta durante a apresentação. Ctrl+C encerra o servidor.')
        print(PRESENTATION_URL)
        webbrowser.open(PRESENTATION_URL)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
