#! /usr/bin/env python

import cgi, cgitb
import urllib.parse
import random
from xmlrpc import client


def get_rand_title():
	pt0 = poem_text.replace('\n', ' ')
	sc = set(['.', ','])
	pt1 = ''.join([c for c in pt0 if c not in sc])
	pta = pt1.split()
	title = ''
	n = random.randint(2, 4)
	for x in range(1, n + 1):
        	title += pta[random.randint(0, len(pta)-1)].strip() + ' ' 
	return(title.strip() + ', por ' + poem_user)

form = cgi.FieldStorage()
p = form.getvalue('poem') 
u = form.getvalue('poem_user')
w = form.getvalue('wp_dir')
if p and u and w:
	poem_text = urllib.parse.unquote(form.getvalue('poem'))
	poem_user = urllib.parse.unquote(form.getvalue('poem_user'))
	wp_dir = urllib.parse.unquote(form.getvalue('wp_dir'))
else:
	exit(1)

user = 'cgi'
with open ("wp-python-password.txt", "r") as f_passwd:
    passwd=f_passwd.read().replace('\n', '')
server = client.ServerProxy('http://telepoesis.net/poemario/xmlrpc.php')
blog_id = 0

#acats = server.wp.getCategories(blog_id, user, passwd)
#cat_id = 0;
#for cat in acats:
#    if cat['description'] == 'wp_dir':
#        cat_id = cat['categoryId']
#        break

blog_content = {
    'post_title': get_rand_title(),
    'post_content': poem_text,
    'post_status': 'publish',
    'post_type': 'post',
    'terms_names': {'category': [wp_dir]}
}

post_id = int(server.wp.newPost(blog_id, user, passwd, blog_content, 0))

print("Content-type:text/html\r\n\r\n")
print("<html>")
print("<head>")
print("<title>Poemario Blog</title>")
print("</head>")
print("<body>")
print("<h2>Thanks %s Posted in %s</h2>" % (poem_user, wp_dir))
print("</body>")
print("</html>")
exit(0)

