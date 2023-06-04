import os, json, argparse, datetime, pathlib, subprocess

class ClipboardManager:
    def __init__(self, clipboardfile):
        self.clipboardfile = clipboardfile
        self.current_datetime = datetime.datetime.now().strftime("%Y %b %d - %H:%M:%S")

        if not os.path.exists(self.clipboardfile):
            print(json.dumps({"ERR": "Clipboard file not found. Creating an empty file..."}))
            pathlib.Path(self.clipboardfile).touch()
            with open(self.clipboardfile, "w") as f:
                tmp = os.popen('wl-paste -t text').read().strip('\n')
                prototype = {"0001": {
                    "date": self.current_datetime,
                    "content": f"{tmp}"
                }}
                jsonout = json.dumps(prototype, indent=3)
                f.write(jsonout)
                f.close()
            exit()


    def args_parser(self):
        arguments = argparse.ArgumentParser(description="Dotfiles Installer")
        arguments.add_argument("-r", "--read"        , action='store_true')
        arguments.add_argument("-R", "--request"     , nargs="*")
        arguments.add_argument("-w", "--write"       , action='store_true')
        arguments.add_argument("-W", "--show-in-wofi", action='store_true')
        x = arguments.parse_args()
        if x.read == True:
            return "read"
        elif x.write == True:
            return "write"
        elif x.request != None:
            return ["request", x.request]
        elif x.show_in_wofi == True:
            return "wofi"


    def show_in_wofi(self):
        count = int(os.popen("ps aux | grep -v grep | grep 'clipboard.py -W' | wc -l").read().strip("\n"))
        if count > 1:
            for a in os.popen("ps aux | grep -v grep | grep -E 'wofi|clipboard.py -W' | awk '{print $2}'").read().split():
                os.kill(int(a), 9)
        else:
            log = self.read_clipboard_file()
            tmp = "\n".join(
                [
                    f"""{key}  ---  {value['date']}  ---  {repr(value['content'])}"""
                    for key, value in sorted(log.items(), reverse=True)
                ]
            )

            tmp2 = subprocess.Popen(["echo", tmp], stdout=subprocess.PIPE)
            out1 = subprocess.check_output(["wofi", "--show", "dmenu", "-k", "/dev/null"], stdin=tmp2.stdout, stderr=subprocess.DEVNULL).decode().split("  ---  ", 2)[2][1:-2].strip("\n")
            tmp3 = subprocess.Popen(["echo", "-ne", out1], stdout=subprocess.PIPE)
            subprocess.Popen("wl-copy", stdin=tmp3.stdout, stdout=subprocess.PIPE)


    def request_clipboard_content(self, request):
        if len(request) == 0 or len(request) > 1:
            print(json.dumps({"ERR": "No Request Specified!!!"}))
            exit(1)

        try:
            if str(request[0]).isnumeric():
                result = self.read_clipboard_file()[request[0]]
            elif request[0] == "latest":
                latestkey = list(self.read_clipboard_file().keys())[-1]
                result = self.read_clipboard_file()[latestkey]
        except:
            return json.dumps({"ERR": f"Request '{request[0]}' Not Found!!!"})
        else:
            return result


    def read_clipboard_file(self):
        if os.path.exists(self.clipboardfile):
            with open(self.clipboardfile) as f:
                return json.load(f)
        else:
            return json.dumps({"ERR": "File Not Found!!!"})


    def save_latest_clipboard_content(self):
        with open(self.clipboardfile, "r+") as f:
            latestkey = str(int(list(self.read_clipboard_file().keys())[-1]) + 1).zfill(4)
            oldcontent = self.read_clipboard_file()
            if os.WEXITSTATUS(os.system("wl-paste -t text &>/dev/null")) != 0:
                exit(1)

            tmp = os.popen('wl-paste -t text').read().strip('\n')
            if tmp:
                prototype = {f"{latestkey}": {
                    "date": self.current_datetime,
                    "content": f"{tmp}"
                }}
                oldcontent.update(prototype)
                jsonout = json.dumps(oldcontent, indent=3)
                f.write(jsonout)
                f.close()


    def run(self):
        if self.args_parser() == "noactions" or not self.args_parser():
            print(json.dumps({"INF": "No Command Specified!!!"}))
            exit()
        elif self.args_parser() == "read":
            print(json.dumps(self.read_clipboard_file()))
        elif self.args_parser() == "write":
            self.save_latest_clipboard_content()
        elif self.args_parser()[0] == "request":
            print(self.request_clipboard_content(self.args_parser()[1]))
        elif self.args_parser() == "wofi":
            self.show_in_wofi()


session = ClipboardManager(f"{os.environ['HOME']}/.cache/clipboard_history.json")
session.run()