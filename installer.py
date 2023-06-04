import os, shutil, argparse, configparser, datetime, stat


class DotfilesInstaller:
    def __init__(self, configfile):
        ## Load Config
        self.configfile = configfile
        self.configpath = self.conf_parser(self.configfile)["includedPaths"]["configpath"]
        self.binpath    = self.conf_parser(self.configfile)["includedPaths"]["binpath"]

        ## Set Colors
        self.FGRED="\033[0;31m"
        self.FGREN="\033[0;32m"
        self.FGYEL="\033[0;33m"
        self.FGRES="\033[0;39m"

        ## Set Path
        os.environ['PATH'] = f"/home/{os.environ['USER']}/{self.binpath}:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        self.home = os.environ['HOME']
        self.pwd  = os.environ['PWD']


    def conf_parser(self, configfile):
        ## ConfigParser
        config = configparser.ConfigParser()
        config.read(configfile)
        dict4config = {s:dict(config.items(s)) for s in config.sections()}
        return dict4config


    def args_parser(self):
        ## ArgumentParser
        arguments = argparse.ArgumentParser(description="Dotfiles Installer")
        arguments.add_argument("-i", "--install", action='store_true')
        arguments.add_argument("-r", "--remove" , action='store_true')
        x = arguments.parse_args()
        if str(x.__dict__.values()).count("False") > 1 or str(x.__dict__.values()).count("True") > 1:
            return "noaction"
        else:
            if x.install == True:
                return "install"
            elif x.remove == True:
                return "remove"


    def check_distro(self):
        ## Check distro name from os-release file
        with open("/etc/os-release", "r") as f:
            tmp = dict()
            for a in f.readlines():
                tmp[a.split("=")[0].strip("\n")] = a.split("=")[1].strip("\n")

            if "ID_LIKE" in tmp:
                if tmp['ID_LIKE'] == "arch":
                    return "pacman -S"
                elif tmp['ID_LIKE'] == "debian":
                    return "apt install"
                elif tmp['ID_LIKE'] == "fedora":
                    return "dnf install"
                elif tmp['ID_LIKE'] == "ubuntu":
                    return "apt install "
                elif tmp['ID_LIKE'] == "opensuse-tumbleweed":
                    return "zypper in"

            if "ID" in tmp:
                if tmp['ID'] == "arch":
                    return "pacman -S"
                elif tmp['ID'] == "debian":
                    return "apt install"
                elif tmp['ID'] == "fedora":
                    return "dnf install"
                elif tmp['ID'] == "ubuntu":
                    return "apt install "
                elif tmp['ID'] == "opensuse-tumbleweed":
                    return "zypper in"
            else:
                return "undefined"


    def check_dependencies(self):
        ## Check requested dependencies
        rapps = self.conf_parser(self.configfile)["requiredApplications"]
        rlibs = self.conf_parser(self.configfile)["requiredLibraries"]
        pm = self.check_distro()

        ## Check Applications
        counter = 0
        for a in range(1, len(rapps) + 1):
            pkgname = rapps[str(a)].split()[0]
            pkgexec = rapps[str(a)].split()[1]
            if not os.popen(f"command -v {pkgexec}").read().strip("\n"):
                print(f"Please install {self.FGREN}{pkgname}{self.FGRES} before proceeding\n{self.FGRED}Example{self.FGRES}: {pm} {pkgname}\n{self.FGYEL}Tip{self.FGRES}: Command is wrong? Visit: https://pkgs.org/download/{pkgname}\n")
                counter += 1

        ## Check Libraries
        for b in range(1, len(rlibs) + 1):
            pkgname = rlibs[str(b)].split()[0]
            libname = rlibs[str(b)].split()[1]
            if not os.popen(f"find /usr/lib* -iname '{libname}' 2>/dev/null | xargs echo").read().strip("\n"):
                print(f"Please install {self.FGREN}{pkgname}{self.FGRES} before proceeding\n{self.FGRED}Example{self.FGRES}: {pm} {pkgname}\n{self.FGYEL}Tip{self.FGRES}: Command is wrong? Visit: https://pkgs.org/download/{pkgname}\n")
                counter += 1

        if counter != 0:
            exit(1)


    def install_dots(self):
        print(self.FGREN, "\b=> Installing Dotfiles...", self.FGRES)

        ## Backup existing dotfiles before installing
        current_datetime = datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S")
        for a in os.listdir(f"{self.pwd}/.config"):
            if self.conf_parser(self.configfile)["main"]["backup"] == "yes":
                os.makedirs(f"{self.home}/.dotbackups/{current_datetime}", exist_ok=True)
                if os.path.exists(f"{self.home}/{self.configpath}/{a}"):
                    print(self.FGYEL, f"\b=> Moving {a} => {self.home}/.dotbackups/{current_datetime}/", self.FGRES)
                    shutil.move(f"{self.home}/{self.configpath}/{a}", f"{self.home}/.dotbackups/{current_datetime}/")
            elif os.path.exists(f"{self.home}/{self.configpath}/{a}"):
                print(self.FGYEL, f"\b=> Moving {a} => {self.home}/{self.configpath}/{a}.{current_datetime}.bak", self.FGRES)
                shutil.move(f"{self.home}/{self.configpath}/{a}", f"{self.home}/{self.configpath}/{a}.{current_datetime}.bak")

        ## Copy New Configs and Files
        for b in os.listdir(f"{self.pwd}/.config"):
            shutil.copytree(f"{self.pwd}/.config/{b}", f"{self.home}/{self.configpath}/{b}", dirs_exist_ok=True)

        if not os.path.exists(f"{self.home}/.fonts") and not os.path.exists(f"{self.home}/{self.binpath}"):
            os.makedirs(f"{self.home}/.fonts/", exist_ok=True)
            os.makedirs(f"{self.home}/{self.binpath}", exist_ok=True)

        for c in os.listdir(f"{self.pwd}/bin"):
            if c.endswith(".ttf") or c.endswith(".otf"):
                shutil.copy(f"{self.pwd}/bin/{c}", f"{self.home}/.fonts/")

        for d in self.conf_parser(self.configfile)["includedPaths"]["customscripts"].split():
            shutil.copy(f"{self.pwd}/bin/{d}", f"{self.home}/{self.binpath}/{d}")
            os.chmod(f"{self.home}/{self.binpath}/{d}", stat.S_IRUSR |
                                                        stat.S_IWUSR |
                                                        stat.S_IXUSR |
                                                        stat.S_IRGRP |
                                                        stat.S_IXGRP |
                                                        stat.S_IROTH |
                                                        stat.S_IXOTH)


        ## Install WPG
        print(self.FGREN, "\b=> Installing extra dependencies...", self.FGRES)
        os.system("pip install pywal --user >/dev/null")
        os.system("pip install pillow --user >/dev/null")
        os.system("pip install wpgtk --user >/dev/null")
        os.system("fc-cache -f >/dev/null")


        print(self.FGREN, "\b=> Installing FlatColor theme, linking dotfiles in wpgtk and applying theme...", self.FGRES)
        os.system("wpg-install.sh -gi >/dev/null")

        if "wpgLinks" in self.conf_parser(self.configfile):
            wpglinks = self.conf_parser(self.configfile)["wpgLinks"]
            for e in range(1, len(wpglinks) + 1):
                linkname = wpglinks[str(e)].split()[0]
                linkpath = wpglinks[str(e)].split()[1]
                if not os.path.islink(f"{self.home}/{self.configpath}/wpg/templates/{linkname}"):
                    os.symlink(f"{self.home}/{linkpath}", f"{self.home}/{self.configpath}/wpg/templates/{linkname}")

        shutil.copy(f"{self.pwd}/bin/gtk2", f"{self.home}/.local/share/themes/FlatColor/gtk-2.0/gtkrc")
        shutil.copy(f"{self.pwd}/bin/gtk3.0", f"{self.home}/.local/share/themes/FlatColor/gtk-3.0/gtk.css")
        shutil.copy(f"{self.pwd}/bin/gtk3.20", f"{self.home}/.local/share/themes/FlatColor/gtk-3.20/gtk.css")
        shutil.copy(f"{self.pwd}/bin/.gtkrc-2.0", f"{self.home}/.gtkrc-2.0")

        if "gtkConfig" in self.conf_parser(self.configfile):
            gtkconfig = self.conf_parser(self.configfile)["gtkConfig"]
            for f in range(1, len(gtkconfig) + 1):
                interfacename = gtkconfig[str(f)].split()[0]
                settingname   = gtkconfig[str(f)].split()[1]
                settingvalue  = gtkconfig[str(f)].split()[2]
                os.system(f"gsettings set {interfacename} {settingname} \'{settingvalue}\'")


    def remove_dots(self):
        print(self.FGYEL, "\b=> Removing dotfiles and restoring old dotfiles...", self.FGRES)
        if "swaydotfiles" not in os.getcwd():
            print(self.FGRED, "\b!! This process is critical. Please take your current location to the \"swaydotfiles\" folder.", self.FGRES)
        else:
            for a in os.listdir(".config"):
                if os.path.exists(f"{self.home}/{self.configpath}/{a}"):
                    shutil.rmtree(f"{self.home}/{self.configpath}/{a}")
                else:
                    print(f"File Not Found: {a}")

                if os.path.exists(f"{self.home}/.dotbackups/{a}"):
                    shutil.copytree(f"{self.home}/.dotbackups/{a}", f"{self.home}/{self.configpath}/{a}", dirs_exist_ok=True)

            for b in self.conf_parser(self.configfile)["includedPaths"]["customscripts"].split():
                try:
                    os.remove(f"{self.home}/{self.binpath}/{b}")
                except FileNotFoundError:
                    print(f"File Not Found: {b}")

    def run(self):
        args = self.args_parser()
        if args == "install":
            self.check_dependencies()
            self.install_dots()
        elif args == "remove":
            self.remove_dots()
        elif args == "twoactions" or args == "noactions":
            print("Wrong Usage!!!")
            exit(1)
        else:
            print("No command specified!!!")
            exit(1)



session = DotfilesInstaller("swaydotfiles.ini")
session.run()
