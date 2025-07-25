#!/bin/bash

# Initialize

# backend
if [ ! -d "/app/backend/.git" ]; then
    echo "Cloning backend repository..."
    cd /app/backend

    git clone git@github.com:SaviorDT/calendar_backend.git .
    cp .env.example .env
    
    # Set .env variables
    sed -i "/^DB_DATABASE=/c\\DB_DATABASE=web_data" .env || echo "DB_DATABASE=web_data" >> .env
    sed -i "/^DB_USERNAME=/c\\DB_USERNAME=web_data" .env || echo "DB_USERNAME=web_data" >> .env
    
    # Password in docker secret
    if [ ! -f /run/secrets/db_web_data_password ]; then
        echo "Error: web_data_password secret not found."
        exit 1
    fi
    DB_WEB_DATA_PASSWORD=$(cat /run/secrets/db_web_data_password)

    sed -i "/^DB_PASSWORD=/c\\DB_PASSWORD=$DB_WEB_DATA_PASSWORD" .env || echo "DB_PASSWORD=$DB_WEB_DATA_PASSWORD" >> .env
    
    # Password in docker secret
    if [ ! -f /run/secrets/gemini_api_key ]; then
        echo "Error: gemeni api key secret not found."
        exit 1
    fi
    GEMINI_API_KEY=$(cat /run/secrets/gemini_api_key)

    sed -i "/^GEMINI_API_KEY=/c\\GEMINI_API_KEY=$GEMINI_API_KEY" .env || echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> .env
    
    echo "Initializing laravel..."
    echo "composer install..."
    composer install --no-interaction --prefer-dist

    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

    # Install passport
    echo "Downloading passport..."
    composer require laravel/passport
    php artisan migrate
    echo "Installing passport..."
    CLIENT_SECRET=$(echo -e "password login\n 0" | php artisan passport:install --no-interaction | grep -oP '(?<=\. ).*' | tail -n 1)
    printf "PASSPORT_CLIENT_ID=2\nPASSPORT_CLIENT_SECRET=$CLIENT_SECRET\n" >> .env
fi

# frontend
if [ ! -d "/app/frontend/.git" ]; then
    echo "Cloning frontend repository..."
    cd /app/frontend

    git clone git@github.com:SaviorDT/calendar_frontend.git .

    npm install
fi

# line bot
if [ ! -d "/app/line_bot/.git" ]; then
    echo "Cloning line bot repository..."
    cd /app/line_bot

    git clone git@github.com:x85432/myLineBot.git .

    # echo "Running pip install for fastapi..."
    # pip install --upgrade pip
    # pip install --no-cache-dir --upgrade -r ./requirements.txt
fi

# discord bot
if [ ! -d "/app/discord_bot/.git" ]; then
    echo "Cloning discord bot repository..."
    cd /app/discord_bot

    git clone git@github.com:SaviorDT/calendar_discord_bot.git .
    cp .env.example .env
    
    # token in docker secret
    if [ ! -f /run/secrets/discord_bot_token ]; then
        echo "Error: discord_bot_token secret not found."
        exit 1
    fi
    DISCORD_BOT_TOKEN=$(cat /run/secrets/discord_bot_token)

    sed -i "/^TOKEN =/c\\TOKEN = $DISCORD_BOT_TOKEN" .env || echo "TOKEN = $DISCORD_BOT_TOKEN" >> .env

    # echo "Running pip install for fastapi..."
    # pip install --upgrade pip
    # pip install --no-cache-dir --upgrade -r ./requirements.txt
fi

# AI agent
# if [ ! -d "/app/ai_agent/.git" ]; then
#     echo "Cloning AI agent repository..."
#     cd /app/ai_agent

#     git clone

#     # echo "Running pip install for fastapi..."
#     # pip install --upgrade pip
#     # pip install --no-cache-dir --upgrade -r ./requirements.txt
# fi


# Pull latest changes
echo "Pulling backend..."
cd /app/backend
git pull
composer install && php artisan migrate

echo "Pulling frontend..."
cd /app/frontend
git pull
npm install

echo "Pulling line bot..."
cd /app/line_bot
git pull
# pip install --no-cache-dir --upgrade -r ./requirements.txt

echo "Pulling discord bot..."
cd /app/discord_bot
git pull

# echo "Pulling AI agent..."
# cd /app/ai_agent
# git pull
# pip install --no-cache-dir --upgrade -r ./requirements.txt