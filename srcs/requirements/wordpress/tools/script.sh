#!/bin/sh
set -x
sleep 10
if [ -e wp-config.php ]; then
	  echo "Wordpress config already created"
else

	wp config create --allow-root \
		--dbname=$db_database \
		--dbuser=$db_user \
		--dbpass=$db_password \
		--dbhost=$db_host

	chmod 600 wp-config.php
fi

if wp core is-installed --allow-root; then
	  echo "Wordpress core already installed"
else

	wp core install --allow-root \
		--url=$DOMAIN_NAME \
		--title=$WP_TITLE \
		--admin_user=$WP_ADMIN_USER \
		--admin_email=$WP_ADMIN_EMAIL \
		--admin_password=$WP_ADMIN_PASSWORD

	wp user create --allow-root \
		$WP_USER \
		$WP_EMAIL \
		--role=author \
		--user_pass=$WP_PASSWORD

	wp config set WP_HOME $DOMAIN_NAME --allow-root
	wp config set WP_SITEURL $DOMAIN_NAME --allow-root
	wp config set WORDPRESS_DEBUG false --allow-root
fi

if !(wp user list --field=user_login --allow-root | grep $WP_USER); then

	wp user create --allow-root \
		$WP_USER \
		$WP_EMAIL \
		--role=author \
		--user_pass=$WP_PASSWORD
fi

wp plugin update --all --allow-root

wp option set comment_moderation 0 --allow-root
wp option set moderation_notify 0 --allow-root
wp option set comment_previously_approved 0 --allow-root
wp option set close_comments_for_old_posts 0 --allow-root   
wp option set close_comments_days_old 0 --allow-root

sed -ie 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/g' \
	/etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;listen.owner = nobody/listen.owner = nobody/g" \
      /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;listen.group = nobody/listen.group = nobody/g" \
      /etc/php/7.4/fpm/pool.d/www.conf
chown -R www-data:www-data /var/www/html/*

exec "$@"