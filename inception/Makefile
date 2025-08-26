# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: irychkov <irychkov@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/26 09:53:53 by irychkov          #+#    #+#              #
#    Updated: 2025/08/26 15:41:46 by irychkov         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception

all:
	@if [ ! -d "/home/irychkov/data/mariadb" ]; then \
		mkdir -p /home/irychkov/data/mariadb; \
	fi
	@if [ ! -d "/home/irychkov/data/wordpress" ]; then \
		mkdir -p /home/irychkov/data/wordpress; \
	fi
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build

down:
	docker compose -f srcs/docker-compose.yml down

fclean: down
	@if [ -d "/home/irychkov/data/mariadb" ]; then \
		rm -rf /home/irychkov/data/mariadb; \
	fi
	@if [ -d "/home/irychkov/data/wordpress" ]; then \
		rm -rf /home/irychkov/data/wordpress; \
	fi
	docker system prune -af --volumes
# rm -rf /home/irychkov/data
# prune removes unused data, -a removes all unused images, not just dangling ones,
# -f forces the removal without confirmation, --volumes removes all unused volumes

re: fclean all

.PHONY: all down fclean re
