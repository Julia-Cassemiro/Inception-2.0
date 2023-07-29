FCOMPOSE=./srcs/docker-compose.yml
ENV_FILE=./srcs/.env
VWORDPRESS=/home/jgomes-c/data/wordpress
VMARIADB=/home/jgomes-c/data/mariadb

all: add_jgomes-c_entry
	@sudo mkdir -pv $(VMARIADB)
	@sudo mkdir -pv $(VWORDPRESS)
	docker-compose -f $(FCOMPOSE) --env-file $(ENV_FILE) up -d --build

add_jgomes-c_entry:
	@if ! grep -q "jgomes-c.42.fr" /etc/hosts; then \
		echo "127.0.0.1 jgomes-c.42.fr" | sudo tee --append /etc/hosts; \
		echo "A entrada foi adicionada ao arquivo /etc/hosts."; \
	else \
		echo "A entrada já existe no arquivo /etc/hosts. Nenhuma alteração feita."; \
	fi

remove_jgomes-c_entry:
	@if grep -q "jgomes-c.42.fr" /etc/hosts; then \
		sudo sed -i '/jgomes-c\.42\.fr/d' /etc/hosts; \
		echo "A entrada foi removida do arquivo /etc/hosts."; \
	else \
		echo "A entrada não foi encontrada no arquivo /etc/hosts. Nenhuma alteração feita."; \
	fi

down:
	docker-compose -f $(FCOMPOSE) --env-file $(ENV_FILE) down

clean: remove_jgomes-c_entry
	docker stop $$(docker ps -qa);\
		docker rm $$(docker ps -qa);\
		docker rmi -f $$(docker images -qa);\
		docker volume rm $$(docker volume ls -q);\
		docker network rm $$(docker network ls -q);\
		sudo rm -rf $(VMARIADB)
		sudo rm -rf $(VWORDPRESS)

.PHONY: all down clean remove_jgomes-c_entry add_jgomes-c_entry