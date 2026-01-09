FROM python:3.11-slim-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    dirmngr \
    fonts-noto-cjk \
    gnupg \
    libpq-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenjp2-7-dev \
    libtiff5-dev \
    libwebp-dev \
    libffi-dev \
    node-less \
    npm \
    python3-magic \
    python3-num2words \
    python3-pdfminer \
    python3-pip \
    python3-phonenumbers \
    python3-pyldap \
    python3-qrcode \
    python3-renderpm \
    python3-setuptools \
    python3-slugify \
    python3-vobject \
    python3-watchdog \
    python3-xlrd \
    python3-xlwt \
    xz-utils \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Create odoo user
RUN useradd -ms /bin/bash odoo

# Install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt

# Copy Odoo source
COPY --chown=odoo:odoo . /opt/odoo
WORKDIR /opt/odoo

# Set permissions
RUN mkdir -p /var/lib/odoo && chown -R odoo:odoo /var/lib/odoo
RUN chmod +x /opt/odoo/odoo-bin

# Expose Odoo ports
EXPOSE 8069 8072

# Set user
USER odoo

# Set entrypoint
ENTRYPOINT ["/opt/odoo/odoo-bin"]
CMD ["--addons-path=/opt/odoo/addons", "--database=odoo"]
