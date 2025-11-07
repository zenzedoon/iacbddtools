FROM python:slim-bullseye
LABEL maintainer="Zied BEN SALEM"
WORKDIR /work

################################
#### Variable Declaration ######
################################
ARG TERRAFORM_VERSION="1.8.0"
ARG TFSWITCH_VERSION="0.14.0"
ARG GOLANG_VERSION="1.20.4"

################################
######## Install tools ########
################################
RUN \
    # Update
    apt-get update -y && \
    # Install Unzip
    apt-get install unzip -y && \
    # need wget
    apt-get install wget -y && \
    # vim
    apt-get install nano -y && \
    # curl
    apt-get install curl -y && \
    # wget
    apt-get install wget -y


################################
######### Install GIT ##########
################################
RUN \
    apt-get update && \
    apt-get install git -y

################################
####### Install Golang #########
################################
# Install Go (for tfswitch installation)
RUN wget https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

################################
####### Install LOLCAT #########
################################
RUN \
    apt-get update -y && \
    apt-get install lolcat -y && apt-get install cowsay -y && apt-get install figlet && \
    gem install lolcat

################################
###### Install Terraform #######
################################
# Download terraform for linux
RUN \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    # Unzip
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    # Move to local bin
    mv terraform /usr/local/bin/ && \
    # Check that it's installed
    terraform --version

################################
######## Install tfswitch ######
################################
RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/master/install.sh | bash && \
    tfswitch --version

################################
####### Install AWS CLI ########
################################
RUN pip install --upgrade awscli && \
    aws --version

################################
###### Install Azure CLI #######
################################
RUN \
    apt-get update && \
    apt-get install ca-certificates curl apt-transport-https lsb-release gnupg -y && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
    AZ_REPO=$(lsb_release -cs) && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install azure-cli && \
    az --version

################################
###### Install Ansible #########
################################
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sshpass \
    python3-pip \
    libffi-dev \
    libssl-dev \
    python3-dev \
    build-essential \
    && pip install --no-cache-dir ansible \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################
###### Install Kubectl #########
################################
RUN \
    apt-get update  && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin && \ 
    kubectl version --client 

################################
###### Install pgtools #########
################################
RUN apt-get update -y && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/* && \
    psql --version

################################
#### Install MongoDB Tools #####
################################
# RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor && \
#     eho "deb http://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
    
# ######

# # Reload local package database
# RUN apt-get update

# # Install the MongoDB packages
# RUN apt-get -y install mongodb-org-shell
# RUN apt-get -y install mongodb-org-tools
# ######    
# RUN apt-get update && \
#     apt-get install -y mongodb-org=8.0.0 mongodb-mongosh=8.0.0 mongodb-org-tools=8.0.0


################################
# Install MSSQL Client Tools
################################
RUN apt-get update -y && \
    apt-get install -y curl && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update -y && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools && \
    rm -rf /var/lib/apt/lists/* && \
    sqlcmd --version

################################
######## Config files ##########
################################
COPY ./BinFiles/* /usr/bin/ 
COPY ./IaCHelp /tmp/IaCHelp
COPY ./ConfigFiles/* /tmp/
RUN chmod 777 /usr/bin/IaCRoleInit && \
    sed -i -e 's/\r$//' /usr/bin/IaCVERSION && \
    chmod 777 /usr/bin/IaCVERSION
################################
# Install SQLcmd - Mongosh - 
#################################

# Install prerequisites for PostgreSQL, MongoDB, and SQL Server tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    apt-transport-https \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && curl -fsSL https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" \
    | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" \
    | tee /etc/apt/sources.list.d/pgdg.list

# Install sqlcmd, mongosh, PostgreSQL client tools, and clean up
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    mssql-tools \
    mongodb-mongosh \
    unixodbc-dev \
    postgresql-client \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/bash.bashrc \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Update PATH to include sqlcmd, mongosh, and PostgreSQL tools
ENV PATH="$PATH:/opt/mssql-tools/bin"