Модулиризация - разбиение приложения на модули, где каждый модуль представляет из себя публичный интерфейс

Эпизод 73:

Проблема: наши view, имеют доступ ко всем состояниям store, мы хотим ограничить
доступ наших view к свойтсвам нашего состояния.

Мы создали функцию view, которя возвращает отделный Store для локального состояния,
но чтобы изменения глобального состояние отслеживались локальным, мы подписываемся на изменения глобального Store
с помощью метода sink

Эпизод 80:

Есть publisher Future, который умеет поставлять данные subscriber - у

var publisher = Future<Int, Never> { callback
	callback(.success(42))
}

ВАЖНО: тело Future запустится сразу, но callback сработает по подписке

Чтобы сделать подписку, можно воспользоваться методом sink, этот метод создаст подписчика в виде 
кложуры и в этой кложуре можно будет обработать присланное значение от publisher - а

ВАЖНО: sink есть только у publisher - ов, которые не могут провалиться (Never)

Чтобы publisher выполнялся по подписке, можно использовать Deffered и обернуть, например, Future
и тогда тело Future сработает только в момент подписки

Future при отправке первого удачного значения, не может больше производить значения и остановиться

PassthroughSubject и CurrentValueSubject это subject: Publisher могут производить значений столько сколько хотят

