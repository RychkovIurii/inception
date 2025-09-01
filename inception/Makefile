# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: irychkov <irychkov@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/26 09:53:53 by irychkov          #+#    #+#              #
#    Updated: 2025/09/01 11:19:21 by irychkov         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception

all:
	@if ! grep -q irychkov /etc/hosts; then \
		echo 127.0.0.1	irychkov.42.fr | sudo tee -a /etc/hosts; \
	fi
	@if [ ! -d "/home/irychkov/data" ]; then \
		mkdir -p /home/irychkov/data; \
	fi
	@if [ ! -d "/home/irychkov/data/mariadb" ]; then \
		mkdir -p /home/irychkov/data/mariadb; \
	fi
	@if [ ! -d "/home/irychkov/data/wordpress" ]; then \
		mkdir -p /home/irychkov/data/wordpress; \
	fi
	docker compose -p $(NAME) -f srcs/docker-compose.yml --env-file srcs/.env up --build

down:
# docker compose -f srcs/docker-compose.yml down
	docker compose -p $(NAME) -f srcs/docker-compose.yml down --remove-orphans

fclean:
# down
	# Stop and remove this project's resources only
	docker compose -p $(NAME) -f srcs/docker-compose.yml --env-file srcs/.env down --rmi local --volumes --remove-orphans
# docker compose -f srcs/docker-compose.yml --env-file srcs/.env down --rmi local --volumes --remove-orphans
	@if [ -d "/home/irychkov/data/mariadb" ]; then \
		sudo rm -rf /home/irychkov/data/mariadb; \
	fi
	@if [ -d "/home/irychkov/data/wordpress" ]; then \
		sudo rm -rf /home/irychkov/data/wordpress; \
	fi
	@if [ -d "/home/irychkov/data" ]; then \
		sudo rm -rf /home/irychkov/data; \
	fi
	sudo sed -i '/irychkov.42.fr/d' /etc/hosts
	docker system prune -a -f --volumes --filter "label=project=$(NAME)"
# prune removes unused data, -a removes all unused images, not just dangling ones,
# -f forces the removal without confirmation, --volumes removes all unused volumes

re: fclean all

.PHONY: all down fclean re
