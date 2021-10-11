from flask import Flask
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)

class Sena(Resource):
    
    def get(self):
        return {"jogo": "04 05 06 12 34 54"}
    
api.add_resource(Sena, '/')

if __name__=='__main__':
    app.run(debug=True)