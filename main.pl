:- include("adjetives.pl").
:- include("verbs.pl").
:- include("verbs2.pl").
:- include("nouns.pl").
:- include("articles.pl").
:- include("phrases.pl").

/*Separa cada palabra del input en una lista para iniciar la traduccion correspondiente */
transLogEI(X,R):-split_string(X," ", "", L),translateEI(L,I),atomic_list_concat(I, ' ', R).
transLogIE(X,R):-split_string(X," ", "", L),translateIE(L,I),atomic_list_concat(I, ' ', R).

transLogEI:-write("Introducir Texto en Espa�ol\n"),read(X),transLogEI(X,Y),write(Y).


transLogIE:-write("Introduce your text in English\n"),read(X),transLogIE(X,Y),write(Y).

translateIE(I,E):-expression(E,I).

/*Reconoce cual es el sujeto y luego identifica el verbo de la oracion. */
translateIE(I,E):- subject(I,Irs,NounEsp,Person,Quantity,_),
translateIE(Irs,Irv,VerbEsp,v,Person,Quantity),
concatenate(NounEsp,VerbEsp,E0),
translateIE(Irv,E1,p),
concatenate(E0,E1,E).

/*Condici�n de parada*/
translateIE([],[],_).

/*Traduce el predicado que se reconoci� de la oraci�n */
translateIE(I,E,p):- predicate(I,E).

/*Dada la persona gramatical y la cantidad busca el verbo que se ajuste a esas mismas condiciones*/
translateIE(I,Ir,E,v,Person,Quantity):- verb(I,Ir,E,Person,Quantity),!.



/* Articulo + sustantivo */
subject([ArticleEng|[NounEng|P]],P,E,t,Quantity,Gender):-
sustantivo(NounEsp,[NounEng],Gender,Quantity),
articulo(ArticleEsp,[ArticleEng],Gender,Quantity),
concatenate(ArticleEsp,NounEsp,E),!.

/*Articulo + sustantivo + adjetivo*/
subject([ArticleEng,AdjEng|[NounEng|P]],P,E,t,Quantity,Gender):-
adjetivo(AdjEsp,[AdjEng],Gender,Quantity),
sustantivo(NounEsp, [NounEng],Gender, Quantity),
articulo(ArticleEsp,[ArticleEng],Gender,Quantity),
concatenate(AdjEsp,NounEsp,Result),
concatenate(ArticleEsp,Result,E),!.

/*Pronombre*/
subject([NounEng|Ir],Ir,NounEsp,Person,Quantity,_):- pronombre(NounEsp,[NounEng],Person,Quantity,_),!.

/*Pregunta, inicia con auxiliar*/
subject([Aux1|[Aux2|Ir]],Ir,ArticleEsp,Gender,Quantity,Tense):- preg(ArticleEsp,[Aux1,Aux2],Gender,Quantity,Tense),!.



/*Identifica el verbo auxiliar y lo conjuga con el siguiente*/
verb([AuxEng|[VerbEng|Pi]],Pi,E,Person,Quantity):- aux(AuxEsp,[AuxEng],Person,Quantity,_),auxInf(VerbEsp,[VerbEng]),concatenate(AuxEsp,VerbEsp,E),!.

/*Si cae aqui es un sujeto con articulo es decir tercera persona*/
verb([VerbEng|T],T,VerbEsp,Person,Quantity):-verbo(VerbEsp,[VerbEng],Person,Quantity,_).
/*Solo identifica el verbo auxiliar*/
verb([AuxEng|Pi],Pi,AuxEsp,Person,Quantity):- aux(AuxEsp,[AuxEng],Person,Quantity,_),!.


predicate(I,NounEsp):- subject(I,_,NounEsp,_,_,_),!.

predicate([Description1,ConjEng,Description2|_],UnionResult):-
predicate(Description1Esp,[Description1]),
predicate(ConjEsp,[ConjEng]),
predicate(Description2Esp,[Description2]),
concatenate(Description1Esp,ConjEsp,Result),
concatenate(Result,Description2Esp,UnionResult),!.

predicate([NounEng|_],NounEsp):- sustantivo(NounEsp,[NounEng],_,_),!.
predicate([AdjEng|_],AdjEsp):- adjetivo(AdjEsp,[AdjEng],_,_),!.
predicate([ConjEng|_],ConjEsp):- conj(ConjEsp,[ConjEng]),!.




translateEI(E,I):- expression(E,I).


translateEI(E,I):- sintagma_nominal(E,Ers,NounEng,Person,Quantity,_),
translateEI(Ers,Erv,VerbEng,v,Person,Quantity),
concatenate(NounEng,VerbEng,I0),
translateEI(Erv,I1,p),
concatenate(I0,I1,I).

translateEI([],[],_).

translateEI(E,I,p):- predicado(E,I).

/*Busca el verbo que se adapta de mejor manera al sujeto*/
/*tradEI(I,Ir,Rv,v,Persona,Cant):- verb(I,Ir,Rv,Cant),!.%Oracion sin auxililar*/
translateEI(E,Er,I,v,Person,Quantity):- sintagma_verbal(E,Er,I,Person,Quantity),!.


sintagma_nominal([ArticleEsp,NounEsp|[Adjesp|P]],P,E,t,Quantity,Gender):-
adjetivo([Adjesp],Adjeng,Gender,Quantity),
sustantivo([NounEsp],NounEng,Gender,Quantity),
articulo([ArticleEsp],ArticleEng,Gender,Quantity),
concatenate(Adjeng,NounEng,F),
concatenate(ArticleEng,F,E),!.

sintagma_nominal([ArticleEsp|[NounEsp|P]],P,E,t,Quantity,Gender):-
sustantivo([NounEsp],NounEng,Gender,Quantity),
articulo([ArticleEsp],ArticleEng,Gender,Quantity),
concatenate(ArticleEng,NounEng,E),!.


/*Pronombre*/
sintagma_nominal([NounEsp|Ir],Ir,NounEng,Person,Quantity,_):- pronombre([NounEsp],NounEng,Person,Quantity,_),!.

/*En espa�ol la conjugacion del verbo decide los auxiliares en ingles*/
sintagma_verbal([VerbEsp|T],T,VerbEng,Person,Quantity):-verbo([VerbEsp],VerbEng,Person,Quantity,_).

predicado(E,NounEsp):- sintagma_nominal(E,_,NounEsp,_,_,_),!.

predicado([Description1,ConjEsp,Description2|_],UnionResult):-
predicado([Description1],Description1Eng),
predicado([ConjEsp],ConjEng),
predicado([Description2],Description2Eng),
concatenate(Description1Eng,ConjEng,Result),
concatenate(Result,Description2Eng,UnionResult),!.

predicado([NounEsp|_],Si):- sustantivo([NounEsp],Si,_,_),!.
predicado([AdjEsp|_],AdjEng):-adjetivo([AdjEsp],AdjEng,_,_),!.
predicado([ConjEsp|_],ConjEng):-conj([ConjEsp],ConjEng),!.

concatenate([],L,L).
concatenate([X|L1],L2,[X|L3]):- concatenate(L1,L2,L3).





