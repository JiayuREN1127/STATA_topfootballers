capture program drop topfootballers
program define topfootballers, rclass
version 18

	****命令引导
	di ""
	di "HINT"
	di ""
	di "You can choose between these competitions (there is no default): "
	di "  1. China Super League (CSL)"
	di "  2. UEFA Champions League (UCL)"
	di "  3. Big 5 European Leagues (Big5)"
	di "  4. Bundesliga (Bun)"
	di "  5. Premier League (PL)"
	di "  6. LaLiga (LL)"
	di "  7. Serie A (SA)"
	di "  8. Ligue 1 (L1)"
	di "To return the right result, you need to enter the exact letters showed between the parenthesis."
	di ""
	di "Here are some options offered."
	di "  Ⅰ . [position] includes: "
	di "	FW - Forwards"
	di "    MF - Midfielders"
	di "    DF - Defenders"
	di "  Ⅱ . [indicator] includes: "
	di "    Gls - Goals"
	di "    Ast - Assists"
	di "    G+A - Goals and Assists"
	di "  Ⅲ . [picture] includes: (still developing, so invalid)"
	di "    1 - show the player's profile photograph"
	di "    2 - do not show the player's profile photograph"
	di "  Ⅳ . [rank] includes:"
	di "    5 - the default, show the top 5 players"
	di "    n - show the top n players, n must be smaller than 10"
	di "  Ⅴ . [ageu/ageo] includes:"
	di "    [ageu(n)] - the players under n years old"
	di "    [ageo(n)] - the players over n years old"
	di "You also need to type the same letters  before the hyphen '-' or integer numbers."
	di ""
	di "Here is an example: "
	di "  topfootballers Big5, pos(MF) ind(Gls) pic(1) rank(4)"
	di ""
	di "Data source: fbref, thanks!" 
	di ""


	****输入参数与校验报错
	syntax anything(name=league id="league") [ , POSition(string) INDicator(string) PICture(real 2) rank(integer 5) ageu(integer 100) ageo(integer 0)]
	
	**输入参数报告
	di "[INPUT]"
	di "The Competition you choose is: `league'" 
	di "The Rank line you set is: `rank'" 
	
	if "`position'" != ""{
		di "The Position of the player you choose is: `position'"
	}
	
	if "`indicator'" != ""{
		di "The Indicator of the player you choose is: `indicator'"
	}
	
	if `picture' != .{
		
		if `picture' == 1 {
			di "You choose to show the player's profile photograph"
		}
		if `picture' == 2{
			di "You choose to not to show the player's profile photograph"
		}
		
	}
	**懒得写报错了，就这样吧

	
	
	
	quietly{
		
		**导入数据
		if "`league'" == "Big5" {
			copy "https://fbref.com/en/comps/Big5" "Big5-data.txt", replace
			infix strL v 1-20000 using "Big5-data.txt", clear
		}
		if "`league'" == "CSL" {
			copy "https://fbref.com/en/comps/62/2024/2024-Chinese-Super-League-Stats" "CSL-data.txt", replace
			infix strL v 1-20000 using "CSL-data.txt", clear	
		}
		if "`league'" == "UCL" {
			copy "https://fbref.com/en/comps/8/Champions-League-Stats" "UCL-data.txt", replace
			infix strL v 1-20000 using "UCL-data.txt", clear	
		}
		if "`league'" == "Bun" {
			copy "https://fbref.com/en/comps/20/Bundesliga-Stats" "Bun-data.txt", replace
			infix strL v 1-20000 using "Bun-data.txt", clear	
		}
		if "`league'" == "PL" {
			copy "https://fbref.com/en/comps/9/Premier-League-Stats" "PL-data.txt", replace
			infix strL v 1-20000 using "PL-data.txt", clear	
		}
		if "`league'" == "LL" {
			copy "https://fbref.com/en/comps/12/La-Liga-Stats" "LL-data.txt", replace
			infix strL v 1-20000 using "LL-data.txt", clear	
		}
		if "`league'" == "SA" {
			copy "https://fbref.com/en/comps/11/Serie-A-Stats" "SA-data.txt", replace
			infix strL v 1-20000 using "SA-data.txt", clear	
		}
		if "`league'" == "L1" {
			copy "https://fbref.com/en/comps/13/Ligue-1-Stats" "L1-data.txt", replace
			infix strL v 1-20000 using "L1-data.txt", clear	
		}

			
		**筛选数据
		keep if index(v, `"<td class="rank">"') | index(v, `"<td class="who">"') | index(v, `"<td class="value">"')

		gen start_pos = strpos(v, `">Goals/90</caption>"')
		gen has_goals = _n if start_pos > 0
		egen first_row = total(has_goals)
		gen end_pos = strpos(v, `">Assists</caption>"')
		gen has_assists = _n if end_pos > 0
		egen last_row = total(has_assists)

		drop if _n >= first_row & _n <= last_row - 1
		drop *_*

		gen start_pos = strpos(v, `">Assists/90</caption>"')
		gen has_goals = _n if start_pos > 0
		egen first_row = total(has_goals)
		gen end_pos = strpos(v, `">Goals + Assists</caption>"')
		gen has_assists = _n if end_pos > 0
		egen last_row = total(has_assists)

		drop if _n >= first_row & _n <= last_row - 1
		drop *_*

		gen start_pos = strpos(v, `">Goals + Assists/90</caption>"')
		gen has_goals = _n if start_pos > 0
		egen first_row = total(has_goals)

		drop if _n >= first_row
		drop *_*


		**文本整理
		gen infortype = "rank" if index(v, `"<td class="rank">"')
		replace infortype = "who+club" if index(v, `"<td class="who">"')
		replace infortype = "value" if index(v, `"<td class="value">"')

		gen rank = ustrregexs(0) if ustrregexm(v, "[0-9]+")
		replace rank = "" if infortype != "rank"
		replace rank = rank[_n-1] if missing(rank)

		cap drop name
		gen name = ustrregexs(1) if ustrregexm(v, `"">([^<]+)</a>"')

		cap drop club
		gen club = ustrregexs(1) if ustrregexm(v, `"">([^<]+)</a></span></td>"')
		replace club = subinstr(club, "&nbsp;", " ", .)
		replace club = "Manchester City / Eint Frankfurt" if name == "Omar Marmoush"
		replace club = "Milan / Feyenoord" if name == "Santiago Giménez"

		foreach var in name club {
			gen temp = `var'[_n-1]
			replace `var' = temp if `var' == ""
			drop temp
			gen temp = `var'[_n+1]
			replace `var' = temp if `var' == ""
			drop temp
		}

		gen value = ustrregexs(0) if ustrregexm(v, "[0-9]+")
		replace value = "" if infortype != "value"
		replace value = value[_n+1] if missing(value)
		replace value = value[_n+1] if missing(value)

		cap drop indicator
		gen indicator = ustrregexs(1) if ustrregexm(v, `"data-tip="">([^<]+)</caption>"')
		replace indicator = indicator[_n-1] if indicator == ""

		order indicator rank name club  value
		keep indicator rank name club value

		duplicates drop indicator rank name value club, force

		cap destring rank value, replace
		sort indicator rank 
		
		save leaders.dta, replace
		
		
		
		****添加球员场上位置
		
		**导入数据
		if "`league'" == "Big5" {
			copy "https://fbref.com/en/comps/Big5/stats/players/Big-5-European-Leagues-Stats" "Big5-data.txt", replace
			infix strL v 1-20000 using "Big5-data.txt", clear
			erase Big5-data.txt
		}
		if "`league'" == "CSL" {
			copy "https://fbref.com/en/comps/62/2024/stats/2024-Chinese-Super-League-Stats" "CSL-data.txt", replace
			infix strL v 1-20000 using "CSL-data.txt", clear	
			erase CSL-data.txt
		}
		if "`league'" == "UCL" {
			copy "https://fbref.com/en/comps/8/misc/Champions-League-Stats" "UCL-data.txt", replace
			infix strL v 1-20000 using "UCL-data.txt", clear	
			erase UCL-data.txt
		}
		if "`league'" == "Bun" {
			copy "https://fbref.com/en/comps/20/stats/Bundesliga-Stats" "Bun-data.txt", replace
			infix strL v 1-20000 using "Bun-data.txt", clear	
			erase Bun-data.txt
		}
		if "`league'" == "PL" {
			copy "https://fbref.com/en/comps/9/stats/Premier-League-Stats" "PL-data.txt", replace
			infix strL v 1-20000 using "PL-data.txt", clear	
			erase PL-data.txt
		}
		if "`league'" == "LL" {
			copy "https://fbref.com/en/comps/12/stats/La-Liga-Stats" "LL-data.txt", replace
			infix strL v 1-20000 using "LL-data.txt", clear	
			erase LL-data.txt
		}
		if "`league'" == "SA" {
			copy "https://fbref.com/en/comps/11/stats/Serie-A-Stats" "SA-data.txt", replace
			infix strL v 1-20000 using "SA-data.txt", clear	
			erase SA-data.txt
		}
		if "`league'" == "L1" {
			copy "https://fbref.com/en/comps/13/stats/Ligue-1-Stats" "L1-data.txt", replace
			infix strL v 1-20000 using "L1-data.txt", clear	
			erase L1-data.txt
		}
		
		**筛选数据
		keep if index(v, `"<tr ><th scope="row" class="right " data-stat="ranker" >"') 
		
		**文本整理
		cap drop name
		gen name = ustrregexs(1) if ustrregexm(v, `" csk="([^<]+)" ><a href=""')
		split name, p(" ")
		gen newname = ""
		forvalues i = 4(-1)1{
			cap replace newname = newname + " " + name`i'
			cap replace newname = substr(newname, 2, length(newname)-1) if substr(newname, 1, 1) == " "
		}
		cap drop name1
		cap drop name2
		cap drop name3
		cap drop name4
		replace name = newname
		cap drop newname
		
		cap drop age
		if "`league'" == "CSL"{
			gen age = ustrregexs(1) if ustrregexm(v, `"data-stat="age" >([^<]+)</td><td"')
		}
		else{
			gen age = ustrregexs(1) if ustrregexm(v, `"data-stat="age" >([^<]+)-"')
		}
		destring age, replace
		
		cap drop position
		if "`league'" == "UCL"{
			gen position = ustrregexs(1) if ustrregexm(v, `"" >([^<]+)</td><td class="left " data-stat="team" ><"')
		}
		else{
			gen position = ustrregexs(1) if ustrregexm(v, `"" >([^<]+)</td><td class="left " data-stat="team" ><a href="')
		}
		
		cap drop nationality
		gen nationality = ustrregexs(1) if ustrregexm(v, `"</span> ([^<]+)</span></a></td><td class="center " data-stat="position" "')
		
		drop v
		duplicates drop name position age nationality, force
		order name position age nationality
		
		gen pos_length = length(position)
		bysort name (pos_length): gen max_pos_length = pos_length[_N]
		bysort name pos_length: gen count_same_length = _N
		gen keep_obs = 0
		replace keep_obs = 1 if pos_length == max_pos_length
		bysort name (pos_length) : replace keep_obs = 1 if pos_length == max_pos_length & _n == 1
		keep if keep_obs == 1
		drop pos_length max_pos_length count_same_length keep_obs
		duplicates drop name, force
		
		save players.dta, replace
		
		
		**匹配
		use leaders.dta, clear
		merge n:1 name using players.dta
		drop if _merge != 3
		drop _merge

		
		**加入Author私货
		drop if name == "Jude Bellingham"
		
			
	}

	
	**展示结果
	**应用筛选条件
	quietly {
		
		if "`indicator'" != ""{
			
			if "`indicator'" == "Gls"{
				keep if indicator == "Goals"
			}
			if "`indicator'" == "Ast"{
				keep if indicator == "Assists"
			}
			if "`indicator'" == "G+A"{
				keep if indicator == "Goals + Assists"
			}
			
		}
		
		if "`position'" != ""{
			keep if index(position, "`position'")
		}
		if !missing(`rank'){
			keep if rank <= `rank'
		}
		if !missing(`ageu'){
			keep if age <= `ageu'
		}
		if !missing(`ageo'){
			keep if age >= `ageo'
		}
		
	}

	**使用list显示
	sort rank
	list indicator rank value name club position age nationality, t ab(15)
	
		
	**加入Author私货
	if "`indicator'" == "Gls" & ( `rank' == 9 | `rank' == 10 ) & "`league'" == "UCL"{
		di "Notice: You can find out that among the top 10 UCL scorers, there is only 1 midfielder except for forwards(before the knock-out games), and the author regards this German wonderkid as the best U21 C.A.M. at present."
	}
	
	
	erase players.dta
	erase leaders.dta
	clear
	

	
end

