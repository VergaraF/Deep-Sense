from flask import Flask
from flask_restful import Resource,Api
from flask import send_file
import os
import p1
import base64
import random
app = Flask(__name__, static_url_path = "", static_folder = "k")


api=Api(app)
##app.config['STATIC_FOLDER'] = 'tmp'

class one(Resource):
    def get(self):
        return'yolo'


class two(Resource):
    def get(self,tags):
        if(tags=='1'):
            p1.f(1)
            k=str(random.randint(0,24))
            f=open('l/generated_chord_'+k+'.mid','rb')
            b=base64.b64encode(f.read())
            return b
        elif(tags=='2'):
            p1.f(2)
            k=str(random.randint(0,24))
            f=open('l/generated_chord_'+k+'.mid','rb')
            b=base64.b64encode(f.read())
            return b
        elif(tags=="3"):
            p1.f(3)
            k=str(random.randint(0,24))
            f=open('l/generated_chord_'+k+'.mid','rb')
            b=base64.b64encode(f.read())
            return b
        elif(tags=="4"):
            p1.f(4)
            k=str(random.randint(0,24))
            f=open('l/generated_chord_'+k+'.mid','rb')
            b=base64.b64encode(f.read())
            return b
            
            


api.add_resource(one,'/da')
api.add_resource(two,'/midi/<string:tags>')
if __name__==('__main__'):
    app.run(host='10.251.194.99')
