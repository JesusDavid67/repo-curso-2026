library(tidyverse)
# 1. Limpieza y cálculo de métricas clave con porcentajes
resumen_con_porcentajes <- balances |> 
  mutate(capital_num = as.numeric(gsub("[^0-9.]", "", as.character(capital_informado)))) |> 
  filter(!is.na(capital_num), capital_num > 0, !is.na(descripcion_tipo_societario)) |> 
  group_by(descripcion_tipo_societario) |> 
  summarize(
    total_sociedades = n(),
    capital_acumulado = sum(capital_num, na.rm = TRUE),
    promedio_capital = mean(capital_num, na.rm = TRUE)
  ) |> 
  mutate(
    pct_empresas = (total_sociedades / sum(total_sociedades)) * 100,
    pct_capital_total = (capital_acumulado / sum(capital_acumulado)) * 100
  ) |> 
  arrange(desc(promedio_capital))

# 2. Formatear la tabla final para la diapositiva
tabla_presentacion <- resumen_con_porcentajes |> 
  slice_max(promedio_capital, n = 5) |> 
  transmute(
    `Tipo Societario` = descripcion_tipo_societario,
    `Cantidad de Empresas` = total_sociedades,
    `% del Total de Empresas` = paste0(round(pct_empresas, 1), "%"),
    `Capital Promedio` = scales::dollar(promedio_capital, prefix = "$", big.mark = ".", decimal.mark = ","),
    `% del Capital Acumulado` = paste0(round(pct_capital_total, 1), "%")
  )

print(tabla_presentacion)