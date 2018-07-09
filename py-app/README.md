# Port of backend to python w/ flask network

based off of https://medium.com/python-pandemonium/build-simple-restful-api-with-python-and-flask-part-2-724ebf04d12

## Getting started

```bash
pip3 install -r requirements.txt
```

```
$ virtualenv venv
$ source venv/bin/activate
$ pip install -r requirements.txt
```

```bash
python3
```

```python
from crud import db
db.create_all()
exit()
```

```bash
$ touch /tmp/mydatabase.db
$ python
>>> from app import db
>>> db.create_all()
>>> quit()
```

## Updating dependencies

```bash
pip3 freeze > requirements.txt
```

## Run app

```bash
python3 run.py
```

## Update models from schema

* `pip3 install sqlacodegen`
  * https://pypi.org/project/sqlacodegen/