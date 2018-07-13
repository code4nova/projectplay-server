# Port of backend to python w/ flask network

based off of https://medium.com/python-pandemonium/build-simple-restful-api-with-python-and-flask-part-2-724ebf04d12

## Getting started

Using Python3.6

```
$ python3.6 -m venv venv
$ source venv/bin/activate
$ pip install -r requirements.txt
```

## Seeder

* `python3 seeder.py` make sure to rename `id` column to `playid` or something else

## Updating dependencies

```bash
pip3 freeze > requirements.txt
```

## Run app

```bash
python3 run.py
```

Json data is at: `/playgrounds.json?callback=?`

## Update models from schema

* `pip3 install sqlacodegen`
  * https://pypi.org/project/sqlacodegen/
