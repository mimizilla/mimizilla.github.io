<html>

<head>
	<link rel="stylesheet" href="kalender_gui.css">
	<link rel="stylesheet" href="kalender.css">
<!--	<link rel="stylesheet" href="desktop_style.css"> -->
</head>

<body>

<cfif not IsDefined("AktuellerMonat") or not IsDefined("AktuellesJahr")>
	<cfset AktuellesDatum = now()>
	<!-- Alle folgenden Variablen, werden in Abhängigkeit von "AktuellesDatum" erzeugt -->
	<cfset AktuellerMonat=Month(AktuellesDatum)>
	<cfset AktuellerTag=Day(AktuellesDatum)>
	<cfset AktuellesJahr=Year(AktuellesDatum)>
</cfif>

<cfset AktuellesDatum = CreateDate(2019,AktuellerMonat,1)>
<cfset zuruckDatum = DateAdd("m", -1, AktuellesDatum)>
<cfset vorDatum = DateAdd("m", +1, AktuellesDatum)>
<cfset zuruckMonat = Month(zuruckDatum)>
<cfset vorMonat = Month(vorDatum)>
<cfset zuruckJahr = Year(zuruckDatum)>
<cfset vorJahr = Year(vorDatum)>
<cfset TageImAktuellenMonat=DaysInMonth(AktuellesDatum)>

<!-- Hier wird das Startdatum festgelegt. Das ist immer der 1.Tag im Monat. -->
<cfset StartDatum = CreateDate(AktuellesJahr, AktuellerMonat, 1)> 
<!-- Hier wird festgelegt welcher Wochentag das Startdatum hat. Der Wochentag kann die Zahlen 1,..,7 annehmen, wobei 1 = Sonntag und 7 = Samstag, entspricht. -->
<cfset StartWochentag = DayOfWeek(StartDatum)> 
<!-- Hier wird das Zieldatum festgelegt. Das ist immer der letzte Tag im Monat. -->	
<cfset ZielDatum = StartDatum + TageImAktuellenMonat-1>
<!-- Hier wird festgelegt welcher Wochentag das Zieldatum hat. Der Wochentag kann die Zahlen 1,..,7 annehmen, wobei 1 = Sonntag und 7 = Samstag, entspricht. -->
<cfset ZielWochentag = DayOfWeek(ZielDatum)>
<cfset TagesSchrittweite = CreateTimeSpan(1, 0, 0, 0)> 
<cfset AktuellerMonatString = MonthAsString(AktuellerMonat)>	
	
<cffile action="read" file="Termine.txt" variable="Termine">
<cfset aTermine = ListToArray(Termine, "#Chr(10)##Chr(13)#")>
<cfset MonatsTermine = ArrayNew(1)>

<cfset d="10041987">

<cfloop array="#aTermine#" index="Row">
	<cfset TerminRow = ListToArray(Row, ";;")>
	<cfset loopDateDiff = DateDiff("d", StartDatum, CreateDate(TerminRow[1],TerminRow[2],TerminRow[3]))>
	<cfif loopDateDiff GTE 0 AND loopDateDiff LTE TageImAktuellenMonat>
		<cfset MonatsTermine.append(ListToArray(Row, ";;"))> 
	</cfif>
</cfloop>
 
<cfset ErsterTagDesMonats = DaysInMonth(AktuellerMonat - 1) - DayOfWeek(CreateDate(Year(AktuellesDatum),Month(AktuellesDatum), 1)) + CreateTimeSpan(1,0,0,0)>
	
	
	<div class="main-a">
		<div class="head">
			KALENDER-GUI
		</div>
		
		<div class="main-b">  
			<div class="navigation"> 
				<div class="nav-item"><a href="responsive_wochenansicht.cfm">Hier gehts zur Wochenansicht </a></div>
				<!-- 1. Form: Monat vor -->
				<div class="nav-item">
					<form method="post" name="form1" action class="button-size">
						<cfoutput>
							<input type="hidden" name="AktuellerMonat" value=#zuruckMonat#>
							<input type="hidden" name="AktuellesJahr" value="#zuruckJahr#">
						</cfoutput>
					 <input type="submit" value="Einen Monat zurück navigieren">
					</form>
				</div>
				<!-- 2. Form: Monat vor -->
				<div class="nav-item">
					<form method="post" name="form2" action>
						<cfoutput>
							<input type="hidden" name="AktuellerMonat" value=#vorMonat#>
							<input type="hidden" name="AktuellesJahr" value="#vorJahr#">
						</cfoutput>
					 <input type="submit" value="Einen Monat vorwärts navigieren">
					</form>
				</div>

				<div class="nav-item">Nav-Item</div>
			</div>
			
			<div class="content"> 
				<!-- hier kommt der Kalender CQ rein -->
				<div class="content-item">
					<table class="kalender-table-border">
						<caption align=top><h1><cfoutput> #AktuellerMonatString# #AktuellesJahr# </cfoutput></h1></caption>
						<head><th class="kalender-index">MO</th><th class="kalender-index">DI</th><th class="kalender-index">MI</th><th class="kalender-index">DO</th><th class="kalender-index">FR</th><th class="kalender-index">SA</th><th class="kalender-index">SO</th></head><br>
						<body>
							<tr>
								<cfloop list="2,3,4,5,6,7,1" index="Wochentag">
									<cfif StartWochentag EQ Wochentag>
										<cfbreak>
									<cfelse>
										<td bgcolor=black></td>
									</cfif>
								</cfloop>

							<cfloop from="#StartDatum#" to="#ZielDatum#" index="loopDate" step="#TagesSchrittweite#"> 
								
								<cfset TERMIN_GEFUNDEN = 0>
								<cfloop array="#MonatsTermine#" index="Row">
									<cfif Year(loopDate) EQ Row[1] AND Month(loopDate) EQ Row[2] and Day(loopDate) EQ Row[3]>
										<cfset TERMIN_GEFUNDEN = 1>
									</cfif>
								</cfloop>
								
								<cfif Day(loopDate) EQ Day(now()) AND Month(loopDate) EQ Month(now())>				<!--aktuellen Tag hervorheben-->
									<cfif TERMIN_GEFUNDEN EQ 1>
										<td class="kalender-table-cell kalender-heutigerTag kalender-termin-gefunden" ><b><cfoutput>#Day(loopDate)#</cfoutput><br>X</b> 
									<cfelse>
										<td class="kalender-table-cell kalender-heutigerTag"><b><cfoutput>#Day(loopDate)#</cfoutput>
									</cfif>
									<form method="post" name="NeuerTermin" action="kalender_termineingabe.cfm">
										<cfoutput>
											<input type="hidden" name="Tag" value="#Day(loopDate)#">
											<input type="hidden" name="Monat" value="#Month(loopDate)#">
											<input type="hidden" name="Jahr" value="#Year(loopDate)#">
										</cfoutput>
										<input type="submit" value="+">
									</form>	
									</td>
								<cfelse>
									<cfif TERMIN_GEFUNDEN EQ 1>
										<td class="kalender-table-cell kalender-termin-gefunden"><cfoutput>#Day(loopDate)#<br><b>X</b></cfoutput>
									<cfelse>
										<td class="kalender-table-cell"><cfoutput>#Day(loopDate)#</cfoutput>
									</cfif>
										<form method="post" name="NeuerTermin" action="kalender_termineingabe.cfm">
											<cfoutput>
												<input type="hidden" name="Tag" value="#Day(loopDate)#">
												<input type="hidden" name="Monat" value="#Month(loopDate)#">
												<input type="hidden" name="Jahr" value="#Year(loopDate)#">
											</cfoutput>
											<input type="submit" value="+">
										</form>	
										</td> 
								</cfif>
								<cfif (DayOfWeek(loopDate)) EQ 1>
									</tr>
								</cfif>
							</cfloop>

							<cfloop index="i" from="#ZielWochentag#" to="7" >
								<td class="kalender-table-cell" bgcolor=black> </td>
							</cfloop>
						<br>
						</body>
					</table>
					<div class="content-termine">
						<cfif ArrayIsEmpty(MonatsTermine) EQ 1>
							Keine Termine in dieser Woche!
						<cfelse>	
							<br><b>Kommende Termine:</b>
							<br>
							<cfloop array="#MonatsTermine#" index="Termin">
								<cfoutput><b>#Termin[1]#-#Termin[2]#-#Termin[3]#:</b> #NumberFormat(Termin[4],"00")#:00 Uhr -- #Termin[5]# - #Termin[6]#<br></cfoutput>
							</cfloop>
						</cfif>
					</div>
				</div>
			</div>
		</div>
		
		<div class="foot"> 
			FOOT
		</div>
	</div>
	
</body>

</html>


	</div>
	
</body>

</html>