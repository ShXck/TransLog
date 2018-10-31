:- include("adjetivos.pl").
:- include("Verbos.pl").
:- include("Verbos2.pl").
:- include("sustantivos.pl").
:- include("articulosYconjunciones.pl").

/*Separa cada palabra del input en una lista para iniciar la traduccion correspondiente */
transLogEI(X,R):-split_string(X," ", "", L),translateEI(L,I),atomic_list_concat(I, ' ', R).
transLogIE(X,R):-split_string(X," ", "", L),translateIE(L,I),atomic_list_concat(I, ' ', R).

transLogEI:-write("Introducir Texto en Español\n"),read(X),transLogEI(X,Y),write(Y).


transLogIE:-write("Introduce your text in English\n"),read(X),transLogIE(X,Y),write(Y).



/*Reconoce cual es el sujero y luego identifica el verbo de la oracion. */
translateIE(I,E):- subject(I,Irs,Se,Persona,Cant,_),
translateIE(Irs,Irv,Ve,v,Persona,Cant),
conc(Se,Ve,E0),translateIE(Irv,E1,p),
conc(E0,E1,E).

/*Condición de parada*/
translateIE([],[],_).

/*Traduce el predicado que se reconoció de la oración */
translateIE(I,E,p):- predicate(I,E).

/*Dada la persona gramatical y la cantidad busca el verbo que se ajuste a esas mismas condiciones*/
translateIE(I,Ir,E,v,Persona,Cant):- verb(I,Ir,E,Persona,Cant),!.%Oracion con auxililar



/* Articulo + sustantivo  getSpaces(I,2,[Ai|Si]),*/
subject([Ai|[Si|P]],P,E,t,Cant,Sexo):-sustantivo(Se,[Si],Sexo,Cant),articulo(Ae,[Ai],Sexo,Cant),conc(Ae,Se,E),!.
/*Pronombre*/
subject([Si|Ir],Ir,Se,Persona,Cant,_):- pronombre(Se,[Si],Persona,Cant,_),!.
/*Pregunta, inicia con auxiliar*/
subject([A1|[A2|Ir]],Ir,Ae,Sexo,Cant,Tiempo):- preg(Ae,[A1,A2],Sexo,Cant,Tiempo),!.



/*Identifica el verbo auxiliar y lo conjuga con el siguiente*/
verb([Avi|[Vi|Pi]],Pi,E,Persona,Cant):- aux(Ave,[Avi],Persona,Cant,_),auxInf(Ve,[Vi]),conc(Ave,Ve,E),!.
/*Si cae aqui es un sujeto con articulo es decir tercera persona*/
verb([Vi|T],T,Ve,Persona,Cant):-verbo(Ve,[Vi],Persona,Cant,_).
/*Solo identifica el verbo auxiliar*/
verb([Avi|Pi],Pi,Ave,Persona,Cant):- aux(Ave,[Avi],Persona,Cant,_),!.



predicate(I,Se):- subject(I,_,Se,_,_,_),!.
predicate([Si|_],Se):- sustantivo(Se,[Si],_,_),!.





translateEI(E,I):- sintagma_nominal(E,Ers,Si,Persona,Cant,_),
translateEI(Ers,Erv,Vi,v,Persona,Cant),
conc(Si,Vi,I0),translateEI(Erv,I1,p),
conc(I0,I1,I).
translateEI([],[],_).
translateEI(E,I,p):- predicado(E,I).
/*Busca el verbo que se adapta de mejor manera al sujeto*/
/*tradEI(I,Ir,Rv,v,Persona,Cant):- verb(I,Ir,Rv,Cant),!.%Oracion sin auxililar*/
translateEI(E,Er,I,v,Persona,Cant):- sintagma_verbal(E,Er,I,Persona,Cant),!.%Oracion con auxililar




sintagma_nominal([Ae,Se|[Adjesp|P]],P,E,t,Cant,Sexo):-
adjetivo([Adjesp],Adjeng,Sexo,Cant),
sustantivo([Se],Si,Sexo,Cant),
articulo([Ae],Ai,Sexo,Cant),
conc(Adjeng,Si,F),
conc(Ai,F,E),!.

sintagma_nominal([Ae|[Se|P]],P,E,t,Cant,Sexo):-
sustantivo([Se],Si,Sexo,Cant),
articulo([Ae],Ai,Sexo,Cant),
conc(Ai,Si,E),!.


/*Pronombre*/
sintagma_nominal([Se|Ir],Ir,Si,Persona,Cant,_):- pronombre([Se],Si,Persona,Cant,_),!.

/*En español la conjugacion del verbo decide los auxiliares en ingles*/
sintagma_verbal([Ve|T],T,Vi,Persona,Cant):-verbo([Ve],Vi,Persona,Cant,_).

predicado(E,Se):- sintagma_nominal(E,_,Se,_,_,_),!.
predicado([Se|_],Si):- sustantivo([Se],Si,_,_),!.



/*Traduce frases de ingles a español*/
tradFIE(Entrada,Trad,Resto):-
frase(_,_,_,Len),
getSpaces(Entrada,Len,Res),
frase(Trad,Res,_,Len),
cutList(Entrada,Len,Resto).

/*Traduce un palabra*/
tradP(E,I):-verbo(E,I).
tradP(E,I):-articulo(E,I).
tradP(E,I):-sustantivo(E,I).
tradP(E,I):-adjetivo(E,I).


/*Obtiene los primeros N espacios de una lista y retorna el resultado*/
getSpaces([H|_],1,[H]).
getSpaces([H|T],N,[H|LR]):-K is N-1,getSpaces(T,K,LR).

/*Recorta N espacios de una lista y retorna el resultado*/
cutList(L,0,L).
cutList([_|T],N,LR):-K is N-1, cutList(T,K,LR).

conc([],L,L).
conc([X|L1],L2,[X|L3]):- conc(L1,L2,L3).


/* Las frases son oraciones que traducidas literalmete no tienen sentido. Siguen el orden:
frase(frase en esp, frase en ing, longitud de la frase en esp,longitud de la frase en ing)*/
frase([cuantos,años,tienes],[how,old,are,you],3,4).
frase([buenos,dias],[good,morning],2,2).





