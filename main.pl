:- include("adjetives.pl").
:- include("verbs.pl").
:- include("nouns.pl").
:- include("articles.pl").
:- include("phrases.pl").

/*Separa cada palabra del input en una lista para iniciar la traduccion correspondiente */
/*UserInput: La frase de entrada.
 * Result: La traduccion.*/
transLogEI(UserInput,Result):-split_string(UserInput," ", "", SplitInput),translateEI(SplitInput,Translation),atomic_list_concat(Translation, ' ', Result).
transLogIE(UserInput,Result):-split_string(UserInput," ", "", SplitInput),translateIE(SplitInput,Translation),atomic_list_concat(Translation, ' ', Result).

transLogEI:-write("Introduzca la frase en ESPA�OL \n"),read(X),transLogEI(X,Y),write(Y).


transLogIE:-write("Introduce the phrase in ENGLISH \n"),read(X),transLogIE(X,Y),write(Y).


translateIE(English,Spanish):-expression(Spanish,English).

/*Reconoce cual es el sujeto y luego identifica el verbo de la oracion.
 * English: Frase en ingl�s.
 * Spanish: Traduccion al espa�ol.*/
translateIE(English,Spanish):- find_subject(English,EnglishTail,NounEsp,Person,Quantity,_),
translateIE(EnglishTail,EnglishVerbTail,VerbEsp,v,Person,Quantity),
concatenate(NounEsp,VerbEsp,Result1),
translateIE(EnglishVerbTail,Result2,p),
concatenate(Result1,Result2,Spanish).

translateIE(English,Spanish):-
translate_by_word_IE(English,[]),
aux(["."],Spanish).

/*Condici�n de parada*/
translateIE([],[],_).

/*Traduce el predicado que se reconoci� de la oraci�n */
translateIE(English,Spanish,p):- find_predicate(English,Spanish).

/*Dada la persona gramatical y la cantidad busca el verbo que se ajuste a esas mismas condiciones
 * English: Lista de frase en ingl�s.
 * EnglishTail: La cola de la frase en ingl�s.
 * Translation: La lista con el resultado de la traducci�n.
 * v: indicador para buscar el verbo.
 * Person: persona gramatical.
 * Quantity: plural o singular.*/
translateIE(English,EnglishTail,Translation,v,Person,Quantity):- find_verb(English,EnglishTail,Translation,Person,Quantity),!.

/*Detecta un sujeto con la forma Demostrativo + Sustantivo
 * DemosEng: demostrativo en ingles.
 * NounEng: Sustantivo en ingl�s.
 * Predicate: el resto de la oraci�n (predicado).
 * Result: lista con elresultado de la traduccion.
 * t: indicador de que se busca sujeto.
 * Quantity: plural o singular.
 * Gender: g�nero.*/
find_subject([DemosEng|[NounEng|Predicate]],Predicate,Result,t,Quantity,Gender):-
sustantivo(NounEsp,[NounEng],Gender,Quantity),
demostrative(DemosEsp,[DemosEng],Gender,Quantity),
concatenate(DemosEsp,NounEsp,Result),!.



/*Detecta un sujeto con la forma Articulo + Sustantivo
 * ArticleEng: Articulo en ingles.
 * NounEng: Sustantivo en ingl�s.
 * Predicate: el resto de la oraci�n (predicado).
 * Result: lista con elresultado de la traduccion.
 * t: indicador de que se busca sujeto.
 * Quantity: plural o singular.
 * Gender: g�nero.*/
find_subject([ArticleEng|[NounEng|Predicate]],Predicate,Result,t,Quantity,Gender):-
sustantivo(NounEsp,[NounEng],Gender,Quantity),
articulo(ArticleEsp,[ArticleEng],Gender,Quantity),
concatenate(ArticleEsp,NounEsp,Result),!.

/*Detecta un sujeto con la forma Articulo + sustantivo + adjetivo
 * ArticleEng: articulo en ingl�s.
 * AdjEng: adjetivo en ingl�s.
 * NounEng: sustantivo en ingl�s.
 * P: predicado, resto de la oraci�n.
 * E: lista de resultado de la traduccion.
 * t: indicador de que se busca sujeto.
 * Quantity: plural o singular.
 * Gender: g�nero.*/
find_subject([ArticleEng,AdjEng|[NounEng|Predicate]],Predicate,E,t,Quantity,Gender):-
adjetivo(AdjEsp,[AdjEng],Gender,Quantity),
sustantivo(NounEsp, [NounEng],Gender, Quantity),
articulo(ArticleEsp,[ArticleEng],Gender,Quantity),
concatenate(AdjEsp,NounEsp,Result),
concatenate(ArticleEsp,Result,E),!.

/*Detecta que un sujeto sea un pronombre
 * NounEng: Pronombre personal en ingl�s.
 * Predicate: el resto de la oraci�n.
 * NounEsp: Pronombre personal en espa�ol.
 * Person: persona gramatical.
 * Quantity: singular o plural.*/
find_subject([NounEng|Predicate],Predicate,NounEsp,Person,Quantity,_):-
pronombre(NounEsp,[NounEng],Person,Quantity,_),!.

/*Detecta los auxiliares de una pregunta
 * Aux1: primer auxiliar.
 * Aux2: segundo auxiliar.
 * Predicate: resto de la oraci�n.
 * ArticleEsp: Articulo en espa�ol.
 * Gender: g�nero.
 * Quantity: plural o singular.
 * Tense: tiempo gramatical.*/
find_subject([Aux1|[Aux2|Predicate]],Predicate,ArticleEsp,Gender,Quantity,Tense):-
preg(ArticleEsp,[Aux1,Aux2],Gender,Quantity,Tense),!.



/*Identifica el verbo auxiliar y lo conjuga
 * AuxEng: Auxiliar en ingl�s.
 * VerbEng: verbo en ingl�s.
 * Predicate: predicado de la oraci�n.
 * Result: lista con el resultado de la traducci�n.
 * Person: persona gramatical.
 * Quantity: plural o singular.*/
find_verb([AuxEng|[VerbEng|Predicate]],Predicate,Result,Person,Quantity):-
aux(AuxEsp,[AuxEng],Person,Quantity,_),auxInf(VerbEsp,[VerbEng]),concatenate(AuxEsp,VerbEsp,Result),!.


/*Encuentra el verbo en tercera persona
 * VerbEng: Verbo en ingl�s.
 * Predicate: resto de la oraci�n.
 * VerbEsp: verbo traducido a espa�ol.
 * Person:persona gramatical.
 * Quantity: plural o singular.*/
find_verb([VerbEng|Predicate],Predicate,VerbEsp,Person,Quantity):-verbo(VerbEsp,[VerbEng],Person,Quantity,_).


/*Identifica verbo auxiliar.
 * AuxEng: auxiliar en ingl�s.
 * Predicate: resto de la oraci�n.
 * AuxEsp: auxiliar traducido a espa�ol.
 * Person: persona gramatical.
 * Quantity: plural o singular.*/
find_verb([AuxEng|Predicate],Predicate,AuxEsp,Person,Quantity):- aux(AuxEsp,[AuxEng],Person,Quantity,_),!.

/*Traduce el predicado de la oraci�n si es un sustantivo
 *English: predicado en ingl�s.
 *NounEsp: sustantivo en espa�ol*/
find_predicate(English,NounEsp):- find_subject(English,_,NounEsp,_,_,_),!.

/*Detecta si el predicado es un sustantivo y adjetivo
 * NounEng: sustantivo en ingl�s.
 * NounEsp: sustantivo traducido.
 * Translation: resultado de la traduccion*/
find_predicate([NounEng,AdjEng|_],Translation):-
translate_word(NounEsp,[NounEng]),
translate_word(AdjEsp,[AdjEng]),
concatenate(AdjEsp,NounEsp,Translation).


/*detecta un predicado con la forma Noun/Adj + conj + Noun/Adj
 * Description1: primer descriptivo en ingl�s.
 * ConjEng: conjunci�n en ingl�s.
 * Description2: segunda descripci�n en ingl�s.
 * UnionResult: resultado de la traducci�n.*/
find_predicate([Description1,ConjEng,Description2|_],UnionResult):-
find_predicate(Description1Esp,[Description1]),
find_predicate(ConjEsp,[ConjEng]),
find_predicate(Description2Esp,[Description2]),
concatenate(Description1Esp,ConjEsp,Result),
concatenate(Result,Description2Esp,UnionResult),!.

/*Detecta si el predicado es un sustantivo
 * NounEng: sustantivo en ingl�s.
 * NounEsp: sustantivo traducido.*/
find_predicate([NounEng|_],NounEsp):- sustantivo(NounEsp,[NounEng],_,_),!.

/*Detecta si el predicado es un adjetivo
 * AdjEng: adjetivo en ingl�s.
 * AdjEsp: adjetivo traducido a espa�ol.*/
find_predicate([AdjEng|_],AdjEsp):- adjetivo(AdjEsp,[AdjEng],_,_),!.

/*Detecta si el predicado es una conjunci�n
 * ConjEng: conjuncion en ingl�s.
 * ConjEsp: conjuncion en espa�ol.*/
find_predicate([ConjEng|_],ConjEsp):- conj(ConjEsp,[ConjEng]),!.

/*Traducci�n Espa�ol -> Ingl�s*/


/*Determina si es una frase que no es traducible con gramatica
 * Spanish: frase en espa�ol.
 * English traduccion al ingl�s.*/
translateEI(Spanish,English):- expression(Spanish,English),!.

/*Determina el sujeto de la oraci�n
 *Spanish: frase en espa�ol.
 *English: traduccion al ingl�s.*/
translateEI(Spanish,English):-
sintagma_nominal(Spanish,Ers,NounEng,Person,Quantity,_),
translateEI(Ers,Erv,VerbEng,v,Person,Quantity),
concatenate(NounEng,VerbEng,Result1),
translateEI(Erv,Result2,p),
concatenate(Result1,Result2,English).

/*Traduce las oraciones palabra por palabra si no cumplen con las sintaxis definidas
 * Spanish: frase en espa�ol.
 * English: traduccion al ingl�s.*/
translateEI(Spanish,English):-
translate_by_word_EI(Spanish,[]),
aux(["."],English).

/*Si la frase es una sola palabra, la traduce
 * Spanish: la palabra en espa�ol.
 * English: traduccion al ingles.*/
translateEI(Spanish,English):-translate_word(Spanish,English),!.

/*Si no entra ninguna palabra*/
translateEI([],[],_).

/*traduce el predicado de la oraci�n
 *Spanish: la frase espa�ol.
 *English: la traduccion al ingl�s.
 *p: indicador de que es predicado*/
translateEI(Spanish,English,p):- predicado(Spanish,English).

/*Busca el verbo que corresponde al sujeto
 * Phrase: la oracion en espa�ol.
 * PhraseTail: el predicado de la oracion.
 * Translation: el resultado de la traduccion.
 * v: indicador de que se busca verbo.
 * Person: persona gramatical.
 * Quantity: plural o singular.*/
translateEI(Phrase,PhraseTail,Translation,v,Person,Quantity):- sintagma_verbal(Phrase,PhraseTail,Translation,Person,Quantity),!.

/*Busca sujeto de la forma Articulo + Sustantivo + adjetivo.
 * ArticleEsp: articulo en espa�ol.
 * NounEsp: sustantivo en espa�ol.
 * AdjEsp: adjetivo en espa�ol.
 * Predicate: resto de la oracion.
 * Result: resultado de la traduccion.
 * t: indicador de sujeto.
 * Quantity: plural o singular.
 * Gender: g�nero.*/
sintagma_nominal([ArticleEsp,NounEsp|[Adjesp|Predicate]],Predicate,Result,t,Quantity,Gender):-
adjetivo([Adjesp],Adjeng,Gender,Quantity),
sustantivo([NounEsp],NounEng,Gender,Quantity),
articulo([ArticleEsp],ArticleEng,Gender,Quantity),
concatenate(Adjeng,NounEng,F),
concatenate(ArticleEng,F,Result),!.

/*Busca sujeto articulo + sustantivo
 * ArticleEsp: articulo en espa�ol.
 * NounEsp: sustantivo en espa�ol.
 * Predicate: resto de la oracion.
 * Result: resultado de la oracion.
 * t: indicador de sujeto.
 * Quantity: plural o singular.
 * Gender: g�nero.*/
sintagma_nominal([ArticleEsp|[NounEsp|Predicate]],Predicate,Result,t,Quantity,Gender):-
sustantivo([NounEsp],NounEng,Gender,Quantity),
articulo([ArticleEsp],ArticleEng,Gender,Quantity),
concatenate(ArticleEng,NounEng,Result),!.

/*Busca sujeto articulo + sustantivo
 * DemosEsp: demostrativo en espa�ol.
 * NounEsp: sustantivo en espa�ol.
 * Predicate: resto de la oracion.
 * Result: resultado de la oracion.
 * t: indicador de sujeto.
 * Quantity: plural o singular.
 * Gender: g�nero.*/
sintagma_nominal([DemosEsp|[NounEsp|Predicate]],Predicate,Result,t,Quantity,Gender):-
sustantivo([NounEsp],NounEng,Gender,Quantity),
demostrative([DemosEsp],DemosEng,Gender,Quantity),
concatenate(DemosEng,NounEng,Result),!.


/*Busca un sujeto pronominal
 * NounEsp: sustantivo en espa�ol.
 * Tail: resto de la oracion.
 * NounEng: sustantivo en ingl�s.
 * Person: persona gramatical.
 * Quantity: plural o singular.*/
sintagma_nominal([NounEsp|Tail],Tail,NounEng,Person,Quantity,_):- pronombre([NounEsp],NounEng,Person,Quantity,_),!.

/*Busca y traduce el verbo
 * VerbEsp: verbo en espa�ol.
 * T: resto de la frase.
 * VerbEng: verbo traducido a ingl�s.
 * Person: persona gramatical.
 * Quantity: plural o singular.*/
sintagma_verbal([VerbEsp|T],T,VerbEng,Person,Quantity):-verbo([VerbEsp],VerbEng,Person,Quantity,_).

/*traduce el predicado
 * Phrase: la oracion.
 * NounEsp: sustantivo en espa�ol.*/
predicado(Phrase,NounEsp):- sintagma_nominal(Phrase,_,NounEsp,_,_,_),!.


/*detecta un predicado con la forma Noun/Adj + conj + Noun/Adj
 * Description1: primer descriptivo en espa�ol.
 * ConjEsp: conjunci�n en espa�ol.
 * Description2: segunda descripci�n en espa�ol.
 * UnionResult: resultado de la traducci�n.*/
predicado([Description1,ConjEsp,Description2|_],UnionResult):-
predicado([Description1],Description1Eng),
predicado([ConjEsp],ConjEng),
predicado([Description2],Description2Eng),
concatenate(Description1Eng,ConjEng,Result),
concatenate(Result,Description2Eng,UnionResult),!.

/*Detecta si el predicado es un sustantivo y adjetivo
 * NounEng: sustantivo en ingl�s.
 * NounEsp: sustantivo traducido.
 * Translation: resultado de la traduccion*/
predicado([NounEsp,AdjEsp|_],Translation):-
translate_word([NounEsp],NounEng),
translate_word([AdjEsp],AdjEng),
concatenate(AdjEng,NounEng,Translation).

/*Detecta si el predicado es un sustantivo
 * NounEng: sustantivo en ingl�s.
 * NounEsp: sustantivo traducido.*/
predicado([NounEsp|_],NounEng):- sustantivo([NounEsp],NounEng,_,_).

/*Detecta si el predicado es un adjetivo
 * AdjEng: adjetivo en ingl�s.
 * AdjEsp: adjetivo traducido a espa�ol.*/
predicado([AdjEsp|_],AdjEng):-adjetivo([AdjEsp],AdjEng,_,_).

/*Detecta si el predicado es una conjunci�n
 * ConjEng: conjuncion en ingl�s.
 * ConjEsp: conjuncion en espa�ol.*/
predicado([ConjEsp|_],ConjEng):-conj([ConjEsp],ConjEng).

/*si no es ninguna de las anteriores traduce la palabra
 * Word: la palabra del predicado.
 * Translation: la traduccion*/
predicado([Word|_],Translation):-translate_word(Word,Translation).

/*Concatena dos listas*/
concatenate([],L,L).
concatenate([X|L1],L2,[X|L3]):- concatenate(L1,L2,L3).

/*Invierte una lista*/
reverse_list([],Result,Result).
reverse_list([H|T],Result,Accumulator):-reverse_list(T,Result,[H|Accumulator]).

/*Traduce una oracion palabra por palabra Espa�ol->Ingl�s.
 * L: el resultado de traduccion*/
translate_by_word_EI([],L):-
reverse_list(L,X,[]),
atomic_list_concat(X, ' ', Result),
write(Result).

/*Traduce una oracion palabra por palabra Espa�ol->Ingl�s.
 * H: primera palabra
 * T: el resto de la oracion.
 * TranslationList: resultado de traduccion.*/
translate_by_word_EI([H|T],TranslationList):-
translate_word([H],Translation),
concatenate(Translation,TranslationList,Result),
translate_by_word_EI(T,Result).

/*Traduce una oracion palabra por palabra Ingl�s->Espa�ol.
 * L: el resultado de traduccion*/
translate_by_word_IE([],L):-
reverse_list(L,X,[]),
atomic_list_concat(X,' ',Result),
write(Result).

/*Traduce una oracion palabra por palabra Ingl�s->Espa�ol.
 * H: primera palabra
 * T: el resto de la oracion.
 * TranslationList: resultado de traduccion.*/
translate_by_word_IE([H|T],TranslationList):-
translate_word(Translation,[H]),
concatenate(Translation,TranslationList,Result),
translate_by_word_IE(T,Result).


/*Traduce una palabra
 * Spanish: la palabra en espa�ol.
 * English: la palabra en ingl�s.*/
translate_word(Spanish,English):-
infinitivo(Spanish,English);
verbo(Spanish,English,_,_,_);
adjetivo(Spanish,English,_,_);
articulo(Spanish,English,_,_);
conj(Spanish,English);
demostrative(Spanish,English,_,_);
question(Spanish,English);
sustantivo(Spanish,English,_,_),!.






