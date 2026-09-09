###DATA TRANSFORMATION--------------------------------------------------------------------------------------------------
library(nycflights13)
library(tidyverse)
flights
glimpse(flights)
flights |>
  filter(dest == "IAH") |> 
  group_by(year, month, day) |> 
  summarize(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  )
##ROWS-------------------------------
#FILTER------------------------------
flights |> 
  filter(dep_delay > 120)
flights |> 
  filter(month == 1 & day == 1)
flights |> 
  filter(month == 1 | month == 2)
flights |> 
  filter(month %in% c(1, 2))
jan1 <- flights |> 
  filter(month == 1 & day == 1)
#COMMON MISTAKES---------------------
flights |> 
  filter(month = 1)
flights |> 
  filter(month == 1 | 2)
#ARRANGE-----------------------------
flights |> 
  arrange(year, month, day, dep_time)
flights |> 
  arrange(desc(dep_delay))
#DISTINCT----------------------------
flights |> 
  distinct()
flights |> 
  distinct(origin, dest)
flights |> 
  distinct(origin, dest, .keep_all = TRUE)
flights |>
  count(origin, dest, sort = TRUE)
#EXERCISE 3.2.5----------------------
#llegar con retraso de 2 horas
flights |> 
  filter(arr_delay >= 120)
#volaron a Houston
flights |> 
  filter(dest %in% c("IAH", "HOU"))
#operados por United, America o Delta
flights |> 
  filter(carrier %in% c("UA", "AA", "DL"))
#salieron en verano(julio, agosto, septiembre)
flights |> 
  filter(month %in% c(7, 8, 9))
#llegaron mas de dos horas tarde(>120), pero no salieron tarde(dep_delay <=0)
flights |> 
  filter(arr_delay > 120 & dep_delay <= 0)
#se retrasaron almenos 1 hora(>=60), pero recuperaron 30 minutos en vuelo
flights |> 
  filter(dep_delay >= 60 & (dep_delay - arr_delay) > 30)
#vuelos con los mayores retrasos de salida
flights |> 
  arrange(desc(dep_delay))
#vuelos que salieron mas temprano en la mañana
flights |> 
  arrange(dep_time)
#encontrar los vuelos mas rapidos(Se calcula la velocidad promedio dividiendo la distancia entre el tiempo de aire y multiplicando por 60 para obtener millas por hora)
flights |> 
  mutate(speed = distance / air_time * 60) |> 
  arrange(desc(speed))
#¿hubo algun vuelo cada dia de 2013? si
flights |> 
  distinct(year, month, day) |> 
  nrow()
#vuelos que recorrieron la mayor distancia
flights |> 
  arrange(desc(distance))
#vuelos que recorrieron la menos distancia
flights |> 
  arrange(distance)
##COLUMNS------------------------------------------------
#MUTATE--------------------------------------------------
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60
  )
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .before = 1
  )
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .after = day
  )
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )
#SELECT---------------------------------------------------
flights |> 
  select(year, month, day)
flights |> 
  select(year:day)
flights |> 
  select(!year:day)
flights |> 
  select(where(is.character))
flights |> 
  select(tail_num = tailnum)
#RENAME---------------------------------------------------
flights |> 
  rename(tail_num = tailnum)
#RELOCATE-------------------------------------------------
flights |> 
  relocate(time_hour, air_time)
flights |> 
  relocate(year:dep_time, .after = time_hour)
flights |> 
  relocate(starts_with("arr"), .before = dep_time)
#EXERCISES 3.3.5------------------------------------------
#formas de seleccionar dep_time, dep_delay, arr_time y arr_delay
#por nombres directos
flights |> select(dep_time, dep_delay, arr_time, arr_delay)
#usando prefijos con start_with()
flights |> select(starts_with("dep_"), starts_with("arr_"))
#usando un vector de caracteres con all_of()
cols <- c("dep_time", "dep_delay", "arr_time", "arr_delay")
flights |> select(all_of(cols))
#usando matches()
flights |> select(matches("^(dep|arr)_(time|delay)$"))
#qué hace any_of() y por qué sirve con el vector
variables <- c("year", "month", "day", "dep_delay", "arr_delay")
flights |> select(any_of(variables))
#sensibilidad a mayúsculas en contains("TIME")
flights |> select(contains("TIME", ignore.case = FALSE))
#renombrar air_time a air_time_min y moverla al principio
flights |> 
  rename(air_time_min = air_time) |> 
  relocate(air_time_min)
#por qué falla flights |> select(tailnum) |> arrange(arr_delay)
flights |> 
  arrange(arr_delay) |> 
  select(tailnum)
##THE PIPE--------------------------------------------------------
flights |> 
  filter(dest == "IAH") |> 
  mutate(speed = distance / air_time * 60) |> 
  select(year:day, dep_time, carrier, flight, speed) |> 
  arrange(desc(speed))
arrange(
  select(
    mutate(
      filter(
        flights, 
        dest == "IAH"
      ),
      speed = distance / air_time * 60
    ),
    year:day, dep_time, carrier, flight, speed
  ),
  desc(speed)
)
flights1 <- filter(flights, dest == "IAH")
flights2 <- mutate(flights1, speed = distance / air_time * 60)
flights3 <- select(flights2, year:day, dep_time, carrier, flight, speed)
arrange(flights3, desc(speed))
##GROUPS----------------------------------------------------------
#GROUP BY--------------------------------------------------------
flights |> 
  group_by(month)
#SUMMARIZE-------------------------------------------------------
flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay)
  )
flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )
flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    n = n()
  )
#SLICE FUNCTION---------------------------------------------------
flights |> 
  group_by(dest) |> 
  slice_max(arr_delay, n = 1) |>
  relocate(dest)
#GROUPING BY MULTIPLE VARIABLES-----------------------------------
daily <- flights |>  
  group_by(year, month, day)
daily
daily_flights <- daily |> 
  summarize(n = n())
daily_flights <- daily |> 
  summarize(
    n = n(), 
    .groups = "drop_last"
  )
#UNGROUPING------------------------------------------------------
daily |> 
  ungroup()
daily |> 
  ungroup() |>
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    flights = n()
  )
#.BY------------------------------------------------------------
flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = month
  )
flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = c(origin, dest)
  )
#EXERCISES 3.5.7------------------------------------------------
#aerolinea con peores retrasos
flights |> 
  group_by(carrier) |> 
  summarize(avg_arr_delay = mean(arr_delay, na.rm = TRUE)) |> 
  arrange(desc(avg_arr_delay))
#vuelos con mayores retrasos de slaida por cada destino
flights |> 
  group_by(dest) |> 
  slice_max(dep_delay, n = 1, with_ties = FALSE) |> 
  relocate(dest, dep_delay)
#variaciones de retrasos a lo largo del dia
library(ggplot2)

flights |> 
  group_by(hour) |> 
  summarize(avg_delay = mean(dep_delay, na.rm = TRUE)) |> 
  ggplot(aes(x = hour, y = avg_delay)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point() +
  labs(
    title = "Retraso promedio según la hora del día",
    x = "Hora del día (0-24 h)",
    y = "Retraso promedio de salida (minutos)"
  )
#evaluacion de data frame pequeño A
#Salida: Muestra las 5 filas originales intactas, agregando la metainformación. Groups: y [2]
#evaluacion de data frame pequeño B
#Salida: Reordena físicamente las filas según y (filas 1, 3 y 4 primero, luego 2 y 5)
##evaluacion de data frame pequeño C
#Salida: Tabla de 2 filas: y = "a" con mean_x = 2.67 y y = "b" con mean_x = 3.5
#evaluacion de data frame pequeño D
#Salida: Tabla de 3 filas con las combinaciones (a-K, a-L, b-K)
#evaluacion de data frame pequeño E
#Salida: Misma tabla de 3 filas que en (d), pero desactiva toda agrupación posterior (ungrouped) y suprime la advertencia
##CASE STUDY-------------------------------------------------------------------------------------------
batters <- Lahman::Batting |> 
  group_by(playerID) |> 
  summarize(
    performance = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    n = sum(AB, na.rm = TRUE)
  )
batters
batters |> 
  filter(n > 100) |> 
  ggplot(aes(x = n, y = performance)) +
  geom_point(alpha = 1 / 10) + 
  geom_smooth(se = FALSE)
batters |> 
  arrange(desc(performance))

###EXERCISES 19.2.4----------------------------------------------------------------------------------------------
##relacion entre weather y airports
#Relación: La columna origin en weather funciona como una clave foránea (foreign key) que hace referencia a la clave primaria faa en la tabla airports
#Representación en el diagrama: Se debe dibujar una flecha que salga desde weather$origin y apunte a airports$faa
##conexión adicional si weather cubriera todo EE. UU
#Si la tabla incluyera el clima de todos los aeropuertos del país, se conectaría con los aeropuertos de llegada en flights:
#La clave foránea compuesta (dest, time_hour) en flights se vincularía con la clave primaria compuesta (origin, time_hour) en la tabla weather
#Esto permitiría conocer las condiciones meteorológicas del destino en el momento exacto del aterrizaje
##la hora duplicada en weather
#al ejecutar
weather |> 
  count(year, month, day, hour, origin) |> 
  filter(n > 1)
#El resultado muestra la fecha 3 de noviembre de 2013 a la 1:00 AM
#En esa fecha finaliza el horario de verano (Daylight Saving Time / DST) en Estados Unidos. A las 02:00 AM los relojes se retrasan una hora, volviendo a marcar la 01:00 AM. Por eso la hora local 1:00 AM se registra dos veces
#La columna time_hour no sufre este duplicado porque almacena la hora en estándar UTC/marca temporal absoluta
##representacion de dias especiales/feriados
#Estructura propuesta (special_days): Un data frame con las columnas year, month, day, holiday_name e is_holiday
#Clave primaria: La combinación compuesta (year, month, day) o una variable date
#Conexión: Se vincula a flights mediante la clave foránea compuesta (year, month, day) apuntando a flights$year, flights$month y flights$day
##relaciones en el paquete Lahman
#diagrama 1 (Batting, People, Salaries):
#People: Clave primaria = playerID
#Batting: Clave primaria compuesta = (playerID, yearID, stint). La columna playerID es clave foránea hacia People$playerID
#Salaries: Clave primaria compuesta = (playerID, yearID, teamID). La columna playerID es clave foránea hacia People$playerID
#diagrama 2 (People, Managers, AwardsManagers):
#People: Clave primaria = playerID
#Managers: Clave primaria compuesta = (playerID, yearID, inseason). Posee playerID como clave foránea hacia People$playerID
#AwardsManagers: Clave primaria compuesta = (playerID, awardID, yearID). Posee playerID como clave foránea hacia People$playerID
#La relación entre Batting, Pitching y Fielding es que son tablas hermanas o paralelas, por lo que Comparten el mismo nivel de agregación (estadísticas por jugador por temporada) y se relacionan entre sí de forma indirecta conectándose a través de la tabla principal People mediante la clave playerID
##EXERCISES 19.3.4
#las 48 horas con peores retrasos y su relación con el clima
worst_48 <- flights |> 
  group_by(time_hour) |> 
  summarize(avg_dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  slice_max(avg_dep_delay, n = 48)

worst_48 |> 
  left_join(weather, join_by(time_hour))
#al cruzar estas horas con la tabla weather, se observa que los peores retrasos coinciden con condiciones meteorológicas severas: rachas de viento elevadas (wind_gust), alta precipitación (precip) y visibilidad reducida (visib), concentradas principalmente en tormentas de verano (junio/julio) o tempestades invernales
#filtrar vuelos hacia los 10 destinos mas populares
flights2 |> 
  semi_join(top_dest, join_by(dest))
#cobertura del clima para cada vuelo de salida
flights |> 
  anti_join(weather, join_by(origin, time_hour))
#patrón en los (tailnum) no encontrados en planes
flights |> 
  anti_join(planes, join_by(tailnum)) |> 
  count(carrier, sort = TRUE)
#Cerca del 90% de las aeronaves que no figuran en planes pertenecen a dos aerolíneas: American Airlines (AA) y Envoy Air (MQ). Estas compañías no reportaron los datos de su flota al registro utilizado por el paquete o empleaban formatos de matrículas distintos
#relacion entre aviones y aerolineas
#¿cada avion es operado por una sola aerolinea?
flights |> 
  filter(!is.na(tailnum)) |> 
  group_by(tailnum) |> 
  summarize(n_carriers = n_distinct(carrier)) |> 
  filter(n_carriers > 1)
#se rechaza la hipótesis: existen 17 matrículas que volaron para más de una aerolínea durante 2013 (debido a transferencias de flota o acuerdos regionales)
#agrega la lista de aerolineas a planes
carrier_map <- flights |> 
  filter(!is.na(tailnum)) |> 
  group_by(tailnum) |> 
  summarize(carriers = paste(unique(carrier), collapse = ", "))

planes_with_carriers <- planes |> 
  left_join(carrier_map, join_by(tailnum))
#agregar latitud y longitud de origen y destino a flights
flights |> 
  select(year, time_hour, origin, dest) |> 
  left_join(
    airports |> select(faa, origin_lat = lat, origin_lon = lon), 
    join_by(origin == faa)
  ) |> 
  left_join(
    airports |> select(faa, dest_lat = lat, dest_lon = lon), 
    join_by(dest == faa)
  )
#mapa de distribución espacial de retrasos por destino
avg_delays <- flights |> 
  group_by(dest) |> 
  summarize(avg_arr_delay = mean(arr_delay, na.rm = TRUE))

airports |> 
  inner_join(avg_delays, join_by(faa == dest)) |> 
  ggplot(aes(x = lon, y = lat, color = avg_arr_delay, size = avg_arr_delay)) +
  borders("state") +
  geom_point(alpha = 0.7) +
  coord_quickmap() +
  scale_color_viridis_c() +
  labs(
    title = "Retraso promedio de llegada según aeropuerto de destino",
    color = "Retraso (min)",
    size = "Retraso (min)"
  )
#que paso el 13 de junio de 2013
june13_delays <- flights |> 
  filter(year == 2013, month == 6, day == 13) |> 
  group_by(dest) |> 
  summarize(avg_arr_delay = mean(arr_delay, na.rm = TRUE))

airports |> 
  inner_join(june13_delays, join_by(faa == dest)) |> 
  ggplot(aes(x = lon, y = lat, color = avg_arr_delay, size = avg_arr_delay)) +
  borders("state") +
  geom_point(alpha = 0.7) +
  coord_quickmap() +
  scale_color_viridis_c() +
  labs(title = "Retrasos de llegada el 13 de junio de 2013")
#El mapa muestra retrasos masivos concentrados en la costa este y el sudeste de los EE. UU. El 12 y 13 de junio de 2013, un fenómeno meteorológico extremo de turbonada (derecho) azotó el Medio Oeste y el Atlántico Medio, provocando tormentas severas, vientos huracanados y la cancelación/retraso masivo de vuelos en toda la región
