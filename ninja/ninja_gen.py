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
                    fragment = Fragment(os.path.join(self.basedir,token))
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
            objs += " " + os.path.join(self.basedir, obj)
        for fragment in self.fragments:
                objs += fragment.get_objects_list()
        return objs

    def write_cc_rules(self,stream):
        for obj in self.objs:
            srcdir = os.path.abspath(self.basedir)
            rule = "build " + os.path.join(self.basedir,obj) + ": "
            rule += "cc " + os.path.join(srcdir,obj)[:-1] + "c\n"
            rule += "  cflags = " + self.cflags + "\n"
            stream.write(rule)
        for fragment in self.fragments:
                fragment.write_cc_rules(stream)

    def __init__(self, basedir=os.path.dirname(os.path.realpath(__file__))):
        self.basedir = basedir
        self.objs = []
        self.fragments = []
        self.cflags = ""
        with open(os.path.join(basedir,"Makefile"),'r') as f:
            content = f.readlines()
            for line in content:
                self._parse_line(line)

if __name__ == '__main__':
    srcdir = sys.argv[1]
    builddir = sys.argv[2]
    os.chdir(srcdir)
    fragment = Fragment(os.path.relpath(srcdir))
    with open(os.path.join(builddir,"build.ninja"),'w') as f:
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

