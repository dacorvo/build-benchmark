import os
import sys
import re

class Fragment(object):

    def _parse_line(self, s):
        s = s.strip()
        if s == "":
            return
        # Matches the first two tokens of a line
        start_re = re.compile(r"([\w-]+)\s*([\+=]+)\s*").match
        match = start_re(s)
        if match == None:
            return
        variable = match.group(1)
        assignment = match.group(2)
        index = match.end()
        length = len(s)
        if variable == "obj-y":
            if assignment == "=":
                self.objs = []
                self.fragments = []
            elif assignment != "+=":
                return
            tokens = s[match.end():].split()
            for token in tokens:
                if token[-1:] == "/":
                    fragment = Fragment(os.path.join(self.base_dir,token,"Makefile"))
                    self.fragments.append(fragment)
                else:
                    self.objs.append(token)
        elif variable == "cflags-y":
            if assignment == "=":
                self.cflags = ""
            elif assignment != "+=":
                return
            self.cflags += s[match.end():]

    def get_objects_list(self):
        objs = ""
        for obj in self.objs:
            objs += " " + os.path.join(self.base_dir, obj)
        for fragment in self.fragments:
                objs += fragment.get_objects_list()
        return objs

    def write_cc_rules(self,stream):
        for obj in self.objs:
            srcdir = os.path.abspath(self.base_dir)
            rule = "build " + os.path.join(self.base_dir,obj) + ": "
            rule += "cc " + os.path.join(srcdir,obj)[:-1] + "c\n"
            rule += "  cflags = " + self.cflags + "\n"
            stream.write(rule)
        for fragment in self.fragments:
                fragment.write_cc_rules(stream)

    def __init__(self, filename="Makefile"):
        self.base_dir = os.path.dirname(filename)
        self.objs = []
        self.fragments = []
        self.cflags = ""
        with open(filename,'r') as f:
            content = f.readlines()
            for line in content:
                self._parse_line(line)

if __name__ == '__main__':
    filename = sys.argv[1]
    output = sys.argv[2]
    fragment = Fragment(filename)
    with open(os.path.join(output,"build.ninja"),'w') as f:
        cc_rule = ("rule cc\n"
                   "  deps = gcc\n"
                   "  depfile = $out.d\n"
                   "  command = cc -MD -MF $out.d $cflags -c $in -o $out\n")

        ld_rule = ("rule ld\n"
                   "  command = cc @$out.rsp -o $out\n"
                   "  rspfile = $out.rsp\n"
                   "  rspfile_content = $in\n")
        f.write(cc_rule)
        f.write(ld_rule)
        fragment.write_cc_rules(f)
        f.write("build foo : ld" + fragment.get_objects_list() + "\n")

