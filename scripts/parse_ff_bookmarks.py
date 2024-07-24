from html.parser import HTMLParser
import re
import json

class MyHTMLParser(HTMLParser):
    tags = []
    tag = None
    href = None
    out = ''
    def handle_starttag(self, tag, attrs):
        self.tag = tag
        if self.tag == 'a':
            for attr in attrs:
                if attr[0] == 'href' :
                    self.href = attr[1]

    def handle_endtag(self, tag):
        if tag == 'dl' and self.tags: self.tags.pop()

    def handle_data(self, data):
        # handle_data seems to get run twice,
        # once with what we want and again with empty data
        if re.fullmatch(r'^[\s]+$', data) != None : return

        if self.tag in ['h3', 'h1']: self.tags += [data]
        if self.tag == 'a':
            self.out += f'{self.href}\n{data}\n{" ".join([f"# {t}" for t in self.tags])}\n\n'
            # o = {
            #     'href' : self.href,
            #     'name': data,
            #     'tags' : self.tags,
            # }

            delim = "\t"
            o = f"{self.href}{delim}{data.strip()}{delim}{' '.join([f'# {t}' for t in self.tags])}"
            print(o)


with open("bookmarks.html", "r") as f:
    src = f.read()

parser = MyHTMLParser()
parser.feed(src)
# print(parser.out)
