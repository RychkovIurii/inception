# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: irychkov <irychkov@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/26 09:53:53 by irychkov          #+#    #+#              #
#    Updated: 2025/08/13 11:32:15 by irychkov         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception

all:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build

down:
	docker compose -f srcs/docker-compose.yml down

fclean: down
	docker system prune -af --volumes
# rm -rf /home/irychkov/data
# prune removes unused data, -a removes all unused images, not just dangling ones,
# -f forces the removal without confirmation, --volumes removes all unused volumes

re: fclean all

.PHONY: all down fclean re
