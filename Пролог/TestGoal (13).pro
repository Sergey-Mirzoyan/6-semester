domains
	name, city, street, mark, color, bank, telephone = symbol.
	house, flat, price, account, sum = integer.
	
	adress = adress(city, street, house, flat).

predicates
	%adress(city, street, house, flat).
        abonent(name, telephone, adress).
        car(name, mark, color, price).
        bank(name, bank, account, sum).
        search_task1(telephone, name, mark, color, price).
        search_task2(name, city, street, bank, telephone).

clauses
        abonent(ivanov, "8800555353", adress(moscow, mayakovskaya, 12, 20)).
        abonent(ivanov, "8888000000", adress(moscow, mayakovskaya, 12, 20)).
        abonent(ivanov, "88885555555", adress(voronez, tupoleva, 13, 24)).
        abonent(kirimov, "89994443322", adress(moscow, tverskaya, 10, 99)).
        abonent(horov, "89924563245", adress(rostov_on_don, pushkinskaya, 15, 51)).
        abonent(dorogov, "83456732245", adress(moscow, motornaya, 87, 92)).
        abonent(dorogov, "89764563892", adress(moscow, motornaya, 87, 92)).
        
        car(ivanov, toyota, white, 100).
        car(ivanov, lexus, black, 150).
        car(horov, bmw, black, 200).
        car(dorogov, audi, green, 170).
        
        bank(ivanov, alfa, 132456, 100).
        bank(ivanov, sber, 134521, 200).
        bank(ivanov, alfa, 134521, 200).
        bank(kirimov, sber, 245212, 150).
        bank(kirimov, vtb, 2451231, 500).
        bank(horov, vtb, 235142, 900).
        bank(dorogov, sber, 2241443, 300).
       
        search_task1(Telephone, Name, Mark, Color, Price) :- abonent(Name, Telephone, adress(_, _, _, _)), car(Name, Mark, Color, Price).
        search_task2(Name, City, Street, Bank, Telephone) :- abonent(Name, Telephone, adress(City, Street,_,_)), bank(Name, Bank, _, _).

goal
	%search_task1("8800555353", Name, Mark, Color, Price).
	%search_task1("8800555353", _, Mark, _, _).
	search_task2(ivanov, moscow, Street, Bank, Telephone).
	
        
