clear all
set more off

global data_row_stata = "G:\Mi unidad\Aguilar - Gutierrez - Tapia\DATA\BASES_PSU\PSU_FORMATO_STATA\"
global data_prepared = "G:\Mi unidad\Aguilar - Gutierrez - Tapia\CARPETA TRABAJO BASES PSU\DATA PREPARED\"



/*=============================*/
/*    PREPARANDO ARCHIVOS A    */
/*          COLEGIOS           */
/*=============================*/
forval ii = 2006/2014 {
use "$data_row_stata\`ii'_archivo_A" ,clear 
*****************************
*********DEPENDENCIA*********
*****************************
destring dependencia ,replace force
label define dependencia ///
 1 "Corporacion Municipal" ///
 2 "Municipal"  ///
 3 "Partticular Subvencionado"  ///
 4 "Particular Pagado" ///
 5 "Corporación de Administración Delegada"
label values dependencia dependencia 
*Municipal 
gen cole_muni = 9999
replace cole_muni  = 1 if inlist(dependencia,1,2)
replace cole_muni = 0 if inlist(dependencia,3,4,5)
label var cole_muni "Municipal School [Yes=1]"
*Part-Pagado
gen cole_part = 9999
replace cole_part  = 1 if inlist(dependencia,4)
replace cole_part = 0 if inlist(dependencia,1,2,3,5)
label var cole_part "Private School [Yes=1]"
*Part_suvb
gen cole_sub = 9999
replace cole_sub = 1 if inlist(dependencia,3)
replace cole_sub  = 0 if inlist(dependencia,1,2,4,5)
label var cole_sub "Subsidized School [Yes=1]"

*****************************
***********REGIMEN***********
*****************************
destring regimen ,replace force
label define regimen 1 "Just Male" 2 "Just Female" 3 "Both Gender"
label values regimen regimen 
label var regimen "School Gender Regimen"
gen just_male = 999
replace just_male  = 1 if inlist(regimen,1)
replace just_male  = 0 if inlist(regimen,2,3) 
label var just_male "Just Male School [Yes =1]"


gen just_female = 999
replace just_female = 1 if inlist(regimen,2)
replace just_female = 0 if inlist(regimen,1,3) 
label var just_female "Just Female  School [Yes =1]"


gen both_gender = 999
replace both_gender  = 1 if inlist(regimen,3)
replace both_gender  = 0 if inlist(regimen,1,2) 
label var both_gender "Mixed School [Yes =1]"

*********************************
*****   RAMA EDUCACIONAL   ******
*********************************
gen rama_X = 999
replace rama_X = 1 if rama_educa =="H1"
replace rama_X = 2 if rama_educa =="H2"
replace rama_X = 3 if rama_educa =="T1"
replace rama_X = 4 if rama_educa =="T2"
replace rama_X = 5 if rama_educa =="T3"

# delimit ;
recode rama_X 
( 1 = 1 "H1 - Humanista Científico Diurno" )
( 2 = 2 "H2 - Humanista Científico Nocturno")
( 3 = 3 "T1 Técnico Profesional Comercial")
( 4 = 4 "T2 Técnico Profesional Industrial")
( 5 = 5 "T3 Técnico Profesional Servicios y Técnica")
,g(rama_edu)
;
# delimit cr 
drop rama_X

gen cole_cientifi = 999
replace cole_cientifi  = 1 if inlist(rama_edu,1,2)
replace cole_cientifi  = 0 if inlist(rama_edu,3,4,5) 
label var cole_cientifi "Scientific School [Yes =1]"


gen cole_tec = 999
replace cole_tec = 1 if inlist(rama_edu,3,4,5)
replace cole_tec = 0 if inlist(rama_edu,1,2) 
label var cole_tec "Technical School [Yes =1]"


/*RENAMING IMPORTANT VARIABLES*/
rename aÑo_proceso year_proceso
capture rename unidad_esducativa unidad_educativa
*UNIQUE IDENTIFIER 
capture rename local_edu   local_educativa
capture rename unidad_edu  unidad_educativa 




/*DROPPING DUPLICATES */
duplicates tag local_educa unidad_educativa , gen(dupli_wrong)
ta dupli_wrong
drop if dupli_wrong ==1
/*Cropping Dataset*/
keep id local_educa unidad_educa year_proceso rama_edu cole_muni cole_part cole_sub  just_male  just_female  both_gender regimen cole_cientifi  cole_tec dependencia

save  "$data_prepared\`ii'_archivo_A_prepared" , replace 
}
*



/*=============================*/
/*    PREPARANDO ARCHIVOS B    */
/*            ALUMNOS          */
/*=============================*/
forval ii = 2006/2014 {
use "$data_row_stata\`ii'_archivo_B" ,clear 
*****************************
*******NACIONALIDAD**********
*****************************
destring nacionalidad ,force replace
label define nacionalidad 1 "Chilean" 2 "Foreing"
label values nacionalidad nacionalidad
**********************
********SEXO**********
**********************
destring sexo ,force replace
replace sexo = 0 if sexo == 2
label define sexo 1 "Male" 0 "Female"
label values sexo sexo
*************************************************
********CUANTOS_TRABAJAN_GRUPO_FAMILIAR**********
*************************************************
destring  cuantos_trabajan_grupo_fam ,replace force
rename cuantos_trabajan_grupo_fam n_trabaj_hog
label variable n_trabaj_hog  "Integrants working household"
*************************************************
********QUIEN_ES_EL_JEFE_DE_FAMILIA**************
*************************************************
destring  quien_es_el_jefe_de_familia , replace force 
# delimit ;
recode quien_es_el_jefe_de_familia 
( 1 = 1 "Applicant's Father" )
( 2 = 2 "Applicant's Mother")
( 3 = 3 "Applicant")
( 4 = 4 "Applicant's Spouse")
( 5 = 5 "Other Applicant's Familiar  ")
( 6 = 6 "Other Person persona")
( 7 = 7 "Grandfather/Grandmother")
( 8= 8 "Applicant's Brother/Sister")
,g(jefe_hogar)
;
# delimit cr 

label variable jefe_hogar "Head of Household"
drop quien_es_el_jefe_de_familia
*************************************************
********   INGRESO BRUTO FAMILIAR  **************
*************************************************
destring ingreso_bruto_fam, replace force
# delimit ;
recode ingreso_bruto_fam 
( 1 = 1 "Between $0 y $144000" )
( 2 = 2 "$144.001 y $288.000")
( 3 = 3 "288.001 y $432.000")
( 4 = 4 "$432.001 y $576.000")
( 5 = 5 "$576.001 y $720.000")
( 6 = 6 "$675.001 y $864.000")
( 7 = 7 "$864.001 y $1.080.000")
( 8= 8 "$1.080.001 y $1.152.000")
( 9= 9 "$1.152.001 y $1.296.000")
( 10= 10 "$1.296.001 y $1.440.000")
( 11= 11 "$1.440.001 y $1.584.000")
( 12= 12 "$1.584.001 and more")
,g(ing_fam_t)
;
# delimit cr 

label variable ing_fam_t "Gross Income Household"

*MARCA DE CLASE
# delimit ;
recode ingreso_bruto_fam 
(0 = 1 ) /*Para recuperar los ingresos iguales a cero*/
(	1	=	72000	)
(	2	=	216000	)
(	3	=	360000	)
(	4	=	504000	)
(	5	=	648000	)
(	6	=	769500	)
(	7	=	972000	)
(	8	=	1116000	)
(	9	=	1224000	)
(	10	=	1368000	)
(	11	=	1512000	)
(	12	=	 1728002	)
,g(ing_fam_mc)
;
# delimit cr 

gen ln_ing_fam_mc =ln(ing_fam_mc)
label variable ln_ing_fam_mc "Ln Gross Income Household"


*************************************
*****EDUCACION_DE_LOS_PADRES*********
*************************************

*PADRE
gen educ_padre_psu= substr( educacion_de_los_padres,1,2)
destring  educ_padre_psu ,replace
# delimit ;
recode educ_padre_psu 
( 1 = 1 "Sin estudios" )
( 2 = 2 "Básica incompleta")
( 3 = 3 "Básica completa")
( 4 = 4 "Media incompleta")
( 5 = 5 "Media completa")
( 6 = 6 "Centro de Formación Técnica incompleta")
( 7 = 7 "Centro de formación Técnica completa")
( 8 = 8 "Universitaria incompleta")
( 9 = 9 "Universitaria completa")
( 10 = 10 "Otros estudios")
( 11 = 11 "Instituto Profesional incompleto")
( 12 = 12 "Instituto Profesional completo")
( 13 = 13 "Desconocida o sin información")
,g(esc_padre)
;
# delimit cr 


gen educ_madre_psu= substr( educacion_de_los_padres,3,4)
destring  educ_madre_psu ,replace
# delimit ;
recode educ_madre_psu 
( 1 = 1 "Sin estudios" )
( 2 = 2 "Básica incompleta")
( 3 = 3 "Básica completa")
( 4 = 4 "Media incompleta")
( 5 = 5 "Media completa")
( 6 = 6 "Centro de Formación Técnica incompleta")
( 7 = 7 "Centro de formación Técnica completa")
( 8 = 8 "Universitaria incompleta")
( 9 = 9 "Universitaria completa")
( 10 = 10 "Otros estudios")
( 11 = 11 "Instituto Profesional incompleto")
( 12 = 12 "Instituto Profesional completo")
( 13 = 13 "Desconocida o sin información")
,g(esc_madre)
;
# delimit cr 

label variable esc_padre "Father's Education Level"
label variable esc_madre "Mother's Education Level"

**GENERATING "MASTER" KEY: RUT
gen largo_cod = strlen(numero_documento)

/*Generando variables string para almacenar la partes del rut*/
	forval i = 7/9 {
	gen str17 rut`i' = "Not Found"
	}
	*
	/*Almacenando partes del rut*/
	replace rut9= substr( numero_documento,1,8)  if largo_cod ==9
	replace rut8= substr( numero_documento,1,7)  if largo_cod ==8
	replace rut7= substr( numero_documento,1,6)  if largo_cod ==7
	/*Llevando a float los string generados*/
	forval i = 7/9 {
	destring rut`i' ,replace force
	replace rut`i' = 0 if rut`i' ==.
	}
	*
	/*Consolidando los rut*/
	gen long ruts =.
	replace ruts = rut9 + rut8 + rut7
	drop rut9 rut8 rut7 largo_cod


/*RENAMING IMPORTANT VARIABLES*/
rename aÑo_proceso year_psu 
rename aÑo_egreso_enseÑanza_media  year_egreso
capture rename unidad_esducativa unidad_educativa

*UNIQUE IDENTIFIER 
capture rename local_edu   local_educativa
capture rename unidad_edu  unidad_educativa 


keep id  numero_documento ruts local_educ unidad_educa year_psu year_egreso nacionalidad sexo n_trabaj_hog jefe_hogar ing_fam_t ing_fam_mc ln_ing_fam_mc  esc_padre esc_madre


save  "$data_prepared\`ii'_archivo_B_prepared" , replace 

}


/*=============================*/
/*    PREPARANDO ARCHIVOS C    */
/*            PUNTAJES          */
/*=============================*/


forval ii = 2006/2014 {
use "$data_row_stata\`ii'_archivo_C" ,clear 

*************************************
**-------------BEA-----------------**
*************************************

if inrange(`ii',2010,2014) {
gen bea_x = 999
replace bea_x = 1 if bea =="BEA"
replace bea_x = 0 if bea_x != 1
label var bea_x "BEA"
drop bea 
rename bea_x bea
}

/*Some years have differents names */
*year_proceso
capture rename aÑo_proceso 		 year_proceso
capture rename aÑo_documento	 year_proceso
capture rename aÑo_psu			 year_proceso

*year_egreso
capture  rename aÑo_egreso 		year_egreso_media
capture rename aÑo_de_egreso 	year_egreso_media



*************************************
**** DEALING WITH RUT *********
*************************************
		**GENERATING "MASTER" KEY: RUT
			gen largo_cod = strlen(numero_documento)

		/*Generando variables string para almacenar la partes del rut*/
			forval i = 7/9 {
			gen str17 rut`i' = "Not Found"
			}
			*
			/*Almacenando partes del rut*/
			replace rut9= substr( numero_documento,1,8)  if largo_cod ==9
			replace rut8= substr( numero_documento,1,7)  if largo_cod ==8
			replace rut7= substr( numero_documento,1,6)  if largo_cod ==7
			/*Llevando a float los string generados*/
			forval i = 7/9 {
			destring rut`i' ,replace force
			replace rut`i' = 0 if rut`i' ==.
			}
			*
			/*Consolidando los rut*/
			gen long ruts =.
			replace ruts = rut9 + rut8 + rut7
			drop rut9 rut8 rut7 largo_cod


*****************************************************
*****   RENOMBRANDO VARIABLES PUNTAJE PSU   *********
*****************************************************
*Selecting List of variables that contains word PTJE
ds , has( varl *PTJE*) /*find variables that contains word PJTJE */
global varlist `r(varlist)' /*Saving it into a global variable*/
local n_variables = wordcount("$varlist")  /*Recovering the number of variables*/

dis `n_variables'

if `n_variables' ==5 {
	*Generating an auxiliar variable to store the names
	gen str16 name_list_`n_variables'= "useless_name"

	local counter = 1
		foreach x in $varlist {
		display "`x'"
		local variable = "`x'"
			replace name_list_`n_variables' = "`variable'" in `counter' 
		local++ counter
		}
	/*For each variable name stored */
		forval i = 1/`n_variables' {
		local v_`i' =  name_list[`i'] /*PTJE_NEM*/	
			dis "`v_`i''"		
		}
		rename ( `v_1' `v_2' `v_3' `v_4' `v_5'  )  ///
		(ptje_nem ptje_leng ptje_mate ptje_hist ptje_cien)			
		destring ptje_* ,replace
		destring year_* ,replace
}
else if `n_variables' ==10 {
	gen str16 name_list_`n_variables'= "useless_name"
	local counter = 1
		foreach x in $varlist {
		display "`x'"
		local variable = "`x'"
			replace name_list_`n_variables' = "`variable'" in `counter' 
		local++ counter
		}
	/*For each variable name stored */
		forval i = 1/`n_variables' {
		local v_`i' =  name_list[`i'] /*PTJE_NEM*/	
			dis "`v_`i''"		
		}
		rename ( `v_1' `v_2' `v_3' `v_4' `v_5' /// 
				 `v_6' `v_7' `v_8' `v_9' `v_10' )  ///
		(ptje_nem ptje_leng ptje_ranking ptje_hist ptje_mate_act ///
		 ptje_cien_act  ptje_leng_ant  ptje_hist_ant ptje_mate_ant ptje_cien_ant)			

		destring ptje_* ,replace
		destring year_* ,replace
		
}



if `n_variables' ==5 {
keep ptje_nem ptje_leng ptje_mate ptje_hist ptje_cien ///
ruts  year_proceso  year_egreso_media  local_educ unidad_educativa numero_documento
}
else if `n_variables' ==10 {
keep ptje_nem ptje_leng ptje_ranking ptje_hist ptje_mate_act ptje_cien_act  ptje_leng_ant  ptje_hist_ant ptje_mate_ant ptje_cien_ant ///
ruts   year_egreso_media year_proceso local_educ unidad_educativa bea numero_documento
}



*UNIQUE IDENTIFIER 
capture rename local_edu   local_educativa
capture rename unidad_edu  unidad_educativa 


duplicates tag numero_documento , gen(dupli_wrong)
ta dupli_wrong
drop if dupli_wrong>0
save  "$data_prepared\`ii'_archivo_C_prepared" , replace 

}



/*=============================*/
/*    CONSOLIDACION ARCHIVOS   */
/*           POR AÑO           */
/*=============================*/

forval ii = 2006/2014 {
dis `ii'
use  "$data_prepared\`ii'_archivo_A_prepared" , clear 
merge 1:m local_edu unidad_educativa using "$data_prepared\`ii'_archivo_B_prepared" ,gen(A_con_B_`ii') force
*drop A_con_B_`ii' ==2 /*No sabemos  a que colegio asistio*/

duplicates tag numero_documento , gen(dupli_wrong)
ta dupli_wrong
drop if dupli_wrong >0
merge 1:1 numero_documento using "$data_prepared\`ii'_archivo_C_prepared" ,gen(AB_con_C_`ii') force
drop if AB_con_C_`ii' == 1 /*Se inscrive, pero no rinde*/

duplicates tag numero_documento , gen(rut_repetidos_`ii')
ta rut_repetidos_`ii'
save  "$data_prepared\`ii'_ABC_prepared" , replace 
}








