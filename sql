#!/bin/bash 

echo "Введите УЗ для работы с MySQL:"; 
read log #Читает пароль

echo "Введите пароль:"; 
read pass #Читает пароль

echo "Введите необходимую директорию для сохранения бэкапов баз данных:";
read dir #Читает директорию

	if [ -d $dir ]; then #Проверяем существует ли такая папка
        echo "Необходимая директория существует";

		#подключаемся к mysql, выводим и записываем в переменную список баз данных
		#после чего с выгружаем их в выбранную ранее директорию dir моментальным снимком с сохранением позиции бинлога
		
		if [ -w $dir ]; then #Проверяем права на запись
        	echo "Есть права на запись в данную директорию";

			mysql -s -r -u"$log" -p"$pass" -e 'show databases' -N > /home/daryushka/database.txt; 
			
			for database in $(cat /home/daryushka/database.txt);
				do mysql -s -r -u"$log" -p"$pass" -e "USE $database;show tables;" -N > /home/daryushka/tables.txt;
			
				for tables in $(cat /home/daryushka/tables.txt); 
					do mysqldump -u"$log" -p"$pass" --complete-insert --triggers --events --routines --single-transaction --source-data=2 "$database" "$tables" > "$dir/$database"_"$tables.sql"; 
				
				done

			done 
		
		else
		
			echo "Вы не имеете права на запись в выбранную директорию. Скрипт будет завершен."	
		
		fi

	else
	
		echo "Указанной директории не существует, требуется создание?"
		echo "1 - Создать директорию и продолжить, любая другая клавиша - выйти из программы"
		read R
	
		if (("$R" == 1)); then
			
			echo "Создаю директорию для бэкапов"
			sudo mkdir -p -m 777 "$dir"

			mysql -s -r -u"$log" -p"$pass" -e 'show databases' -N > /home/daryushka/database.txt; 
			
			for database in $(cat /home/daryushka/database.txt);
				do mysql -s -r -u"$log" -p"$pass" -e "USE $database;show tables;" -N > /home/daryushka/tables.txt;
			
				for tables in $(cat /home/daryushka/tables.txt); 
					do mysqldump -u"$log" -p"$pass" --complete-insert --triggers --events --routines --single-transaction --source-data=2 "$database" "$tables" > "$dir/$database"_"$tables.sql"; 
				
				done

			done 

		else
		
			echo "Скрипт будет завершен"

    	fi

	fi
