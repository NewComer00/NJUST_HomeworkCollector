# -*- coding: utf-8 -*-

import os

# environment var parser
from envparse import env

# random string
import uuid

# database
import csv

# time mark
import time
from datetime import datetime
import pytz

# for secure_filename
import unicodedata
import re

# flask
from flask import Flask, render_template, request, redirect, url_for, flash, Markup, jsonify
from flask_wtf import FlaskForm, CSRFProtect
from flask_wtf.file import FileField, FileAllowed, FileRequired
from wtforms import StringField, SubmitField, BooleanField, PasswordField, IntegerField, TextField,\
    FormField, SelectField, FieldList
from wtforms.validators import DataRequired, Length, Regexp
from wtforms.fields.html5 import *
from werkzeug.exceptions import HTTPException, default_exceptions, _aborter

# bootstrap for flask
from flask_bootstrap import Bootstrap


HOMEWORK_NUMBER = env('HOMEWORK_NUMBER', cast=int,
        default=1)
PAGE_HEADER = env('PAGE_HEADER', cast=str,
        default="云数据管理课程")
APP_ROOT = env('APP_ROOT', cast=str,
        default=os.path.dirname(os.path.realpath(__file__)))

print(HOMEWORK_NUMBER)

UPLOAD_FOLDER = r'uploads/%d/' % HOMEWORK_NUMBER
UPLOAD_FOLDER = os.path.join(APP_ROOT, UPLOAD_FOLDER)
DATABASE_FILE = r'database/%d/records.csv' % HOMEWORK_NUMBER
DATABASE_FILE = os.path.join(APP_ROOT, DATABASE_FILE)

# allowed types and size for files to be uploaded
ALLOWED_EXTENSIONS = ['zip']
MAX_CONTENT_LENGTH = 100 * 1024 * 1024

app = Flask(__name__)
app.config['SECRET_KEY'] = str(uuid.uuid4())  # a random string
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH

# set default button sytle and size, will be overwritten by macro parameters
app.config['BOOTSTRAP_BTN_STYLE'] = 'primary'
app.config['BOOTSTRAP_BTN_SIZE'] = 'lg btn-block'
# app.config['BOOTSTRAP_BOOTSWATCH_THEME'] = 'lumen'  # uncomment this line to test bootswatch theme

bootstrap = Bootstrap(app)


class ExampleForm(FlaskForm):
    name = StringField("姓名",
               render_kw={'placeholder': "英雄，请留下姓名！"},
               validators=[DataRequired("英雄，请留下姓名！"),
               Length(min=2,max=20,message="用户名字数应为2~20哟~")])
    number = StringField("学号",
               render_kw={'placeholder': "学号也请留下"},
               validators=[DataRequired("学号也请留下"),
               Regexp(regex=r'^([a-z]|[A-Z]|[0-9]){11,12}$',message="学号需要11~12位数字或字母")])
    file = FileField("上传zip文件",
               validators=[FileRequired("记得上传文件"),
               FileAllowed(ALLOWED_EXTENSIONS,message="文件格式必须是zip")])
    submit = SubmitField("提交")


def secure_filename(filename: str):
    r"""
    Adapted from werkzeug.utils.secure_filename for Chinese support.
    Ref:  https://blog.csdn.net/qq_36390239/article/details/98847888
    """
    filename = unicodedata.normalize("NFKD", filename)
    filename = filename.encode("utf-8", "ignore").decode("utf-8")

    for sep in os.path.sep, os.path.altsep:
        if sep:
            filename = filename.replace(sep, " ")

            filename_chinese_add_strip_re = re.compile(r'[^A-Za-z0-9_\u4E00-\u9FBF.-]')
            filename = str(filename_chinese_add_strip_re.sub('', '_'.join(
                filename.split()))).strip('._')

    # on nt a couple of special files are present in each folder.  We
    # have to ensure that the target file is not such a filename.  In
    # this case we prepend an underline
    if (
        os.name == "nt"
        and filename
        and filename.split(".")[0].upper() in _windows_device_files
    ):
        filename = f"_{filename}"

    return filename


def add_to_db(db_file, data):
    os.makedirs(os.path.dirname(db_file), exist_ok=True)
    with open(db_file, "a+", newline='') as file:
        csv_file = csv.writer(file)
        csv_file.writerow(data)


@app.route('/', methods=['GET', 'POST'])
def test_form():
    form = ExampleForm()

    if request.method == 'GET':
        return render_template('form.html', form=form,
                homework_number=HOMEWORK_NUMBER,
                page_header=PAGE_HEADER)

    if request.method == 'POST':
        if form.validate():
            student_name = form.name.data
            student_num = form.number.data
            homework_file = form.file.data

            filename = secure_filename(homework_file.filename)
            file_format = filename.rsplit('.', 1)[1].lower()
            filename = '%d_%s_%s.%s' % (HOMEWORK_NUMBER,student_name,student_num,file_format)

            os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
            homework_file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

            time_mark = datetime.fromtimestamp(int(time.time()),
                        pytz.timezone('Asia/Shanghai')).strftime('%Y-%m-%d %H:%M:%S %Z%z')
            record = [student_name,
                      student_num,
                      filename,
                      secure_filename(homework_file.filename),
                      time_mark
                      ]
            add_to_db(DATABASE_FILE, record)
            flash("文件上传成功！", 'success')
            return redirect(url_for('test_form'))

        else:
            for err_field,err_msg in form.errors.items():
                for err in err_msg:
                    flash(err, 'danger')
            return redirect(url_for('test_form'))


@app.errorhandler(404)
def page_404(e):
    return render_template('404.html'), 404


class TripleFive(HTTPException):
    code = 555
default_exceptions[555] = TripleFive
_aborter.mapping[555] = TripleFive
@app.errorhandler(555)
def page_555(e):
    return render_template('555.html'), 555


if __name__ == '__main__':
    app.run(host = '0.0.0.0')
