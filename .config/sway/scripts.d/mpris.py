import dbus, argparse, json
class mprisHandler:
    ###############################
    #
    ## BUS / Interface
    #
    ###############################
    def __init__(self):
        self.bus = dbus.SessionBus()
        try:
            self.proxy = self.bus.get_object([a for a in self.bus.list_names() if "mpris" in a][0], '/org/mpris/MediaPlayer2')
        except:
            print(json.dumps({"text": "--:--:--"}))
            exit()
        else:
            self.props = dbus.Interface(self.proxy, 'org.freedesktop.DBus.Properties')

    ###############################
    #
    ## Microsecond Handler
    #
    ###############################
    def microSecondHandler(self, microsecond):
        second = int(divmod(divmod(microsecond, 1000)[0], 1000)[0])
        minute = divmod(second, 60)[0]
        hour   = divmod(minute, 60)[0]
        return [str(hour % 24).zfill(2), str(minute % 60).zfill(2), str(second % 60).zfill(2)]

    ###############################
    #
    ## Data Request
    #
    ###############################
    def req(self, name):
        return self.props.Get('org.mpris.MediaPlayer2.Player', name)

    ###############################
    #
    ## Print Human Readable Output
    #
    ###############################
    def output(self, *args):
        arg       = args[0]
        arguments = arg["arguments"]
        if (arguments != None):
            try:
                return json.dumps({arguments: args[0][arguments]})
            except KeyError:
                return json.dumps({"error": f"{arguments} is not defined"})
        else:
            position   = arg["position"]
            songname   = arg["songname"]
            songlength = arg["songlength"]
            status     = arg["status"]

            if status == "Playing":
                icon = "  "
            else:
                icon = "  "

            #dp = f"{position} | {songname} | {songlength}"
            return json.dumps({"text": f"{icon} {position}/{songlength}", "tooltip": songname})
            
    ###############################
    #
    ## Run!!!
    #
    ###############################
    def parseArgs(self):
        self.parser = argparse.ArgumentParser(description='MPRIS Helper')
        self.parser.add_argument("-g", "--get", required=False, metavar="position|duration|songname")
        return self.parser.parse_args()

    def checkvalue(self, value):
        try:
            tmp = value
        except:
            return "undefined"
        else:
            return value

    def run(self):
        arguments = self.parseArgs()
        try:
            status       = self.checkvalue(self.req("PlaybackStatus"))
            __position   = self.checkvalue(self.req("Position"))
            position     = ":".join(self.microSecondHandler(__position))
            __metadata   = self.checkvalue(self.req("Metadata"))
            if "xesam:title" in __metadata.keys():
                songname = self.checkvalue(__metadata['xesam:title'])
            elif "xesam:url" in __metadata.keys():
                songname = self.checkvalue(__metadata['xesam:url'])
            __songlength = self.checkvalue(__metadata['mpris:length'])
            songlength   = ":".join(self.microSecondHandler(__songlength))
        except:
            status     = "Paused"
            position   = "--:--:--"
            songname   = "Paused"
            songlength = "--:--:--"
            

        print(self.output({
            "position"  :  position,
            "songname"  :  songname,
            "songlength":  songlength,
            "status"    :  status,
            "arguments" :  arguments.get
        }))


s = mprisHandler()
s.run()
