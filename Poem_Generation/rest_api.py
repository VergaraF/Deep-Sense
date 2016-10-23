#Program to create the web server and receive and send data to the client


from flask import Flask, request, send_from_directory
from flask_restful import Resource, Api
import final_test as ft

app = Flask(__name__)
api = Api(app)

class story(Resource):
    def get(self):
        result = {'data' : "data", 'name' : "foo"}
        return result

class story_more(Resource):
    def get(self, tags, code):
        get_poem = ft.accept_request(tags, code)
        return get_poem

class img(Resource):
    def get(self, path):
        return send_from_directory('/PycharmProjects/RNNs/', path)

class file(Resource):
    def get(self):
        f = open('t.s_eliot_train_data.txt').read()
        return f

#api.add_resource(story, '/da')
api.add_resource(story_more, '/dad/<string:tags>/<int:code>')
#api.add_resource(img, '/pa/<path:path>')
#api.add_resource(file, '/im')


if __name__=='__main__':
    app.run(host='10.251.202.68')

