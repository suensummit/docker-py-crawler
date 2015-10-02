FROM c3h3/pyenv

MAINTAINER Summit Suen <summit.suen@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV HOME /root
ENV PYENVPATH $HOME/.pyenv
ENV PATH $PYENVPATH/shims:$PYENVPATH/bin:$PATH

RUN apt-get update && apt-get -y install git-core build-essential gfortran sudo make cmake libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm vim

RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

RUN echo 'eval "$(pyenv init -)"' >  /root/.bashrc

RUN pyenv install anaconda-2.3.0 && \
    pyenv global anaconda-2.3.0 && \
    conda update anaconda

COPY requirements.txt /tmp/

RUN pip install -r /tmp/requirements.txt

RUN ipython profile create

RUN (echo "require(['base/js/namespace'], function (IPython) {" && \
     echo "  IPython._target = '_self';" && \
     echo "});") \
     > /root/.ipython/profile_default/static/custom/custom.js

RUN (echo "c = get_config()" && \
     echo "headers = {'Content-Security-Policy': 'frame-ancestors *'}" && \
     echo "c.NotebookApp.allow_origin = '*'" && \
     echo "c.NotebookApp.allow_credentials = True" && \
     echo "c.NotebookApp.tornado_settings = {'headers': headers}" && \
     echo "c.NotebookApp.ip = '0.0.0.0'" && \
     echo "c.NotebookApp.open_browser = False" && \
     echo "from IPython.lib import passwd" && \
     echo "import os" && \
     echo "c.NotebookApp.password = passwd(os.environ.get('PASSWORD', 'jupyter'))") \
     > /root/.ipython/profile_default/ipython_notebook_config.py

EXPOSE 8888

CMD ipython notebook --ip=0.0.0.0 --port 8888 --profile=$IPYNB_PROFILE
