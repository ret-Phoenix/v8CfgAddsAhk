#Использовать gui

// Общий доступ к переменным
Перем Форма;
Перем ПолеПоиска;
Перем ПолеСписка;
Перем ДанныеСписка;

Функция ПолучитьТекстИзФайла(ИмяФайла) Экспорт
	ФайлОбмена = Новый Файл(ИмяФайла);
	Данные = "";
	Если ФайлОбмена.Существует() Тогда
		Текст = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.ANSI);
		Данные = Текст.Прочитать();
		Текст.Закрыть();
		ОсвободитьОбъект(Текст);
	КонецЕсли;
	возврат Данные;
КонецФункции

Функция ЗаписатьРезультатВФайл(ИмяФайла, Данные) Экспорт
	Текст = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.ANSI); 
	Текст.Записать(Данные); 
	Текст.Закрыть();		
	ОсвободитьОбъект(Текст);
КонецФункции // ЗаписатьРезультатВФайл(ИмяФайла,Данные)

Функция ЗапускПриложенияВзаимодействия(Приложение, Данные, Очищать=10, СписокВыбораВФайл="")

	ЗаписатьРезультатВФайл("tmp\app.txt", Данные);
	Если СписокВыбораВФайл <> "" Тогда
		ЗаписатьРезультатВФайл(СписокВыбораВФайл, Данные);
	КонецЕсли;
	ЗапуститьПриложение("system\" + Приложение + ".exe tmp\app.txt",, true);

	Стр = СокрЛП(ПолучитьТекстИзФайла("tmp\app.txt"));
	Если Очищать = 1 Тогда
		ЗаписатьРезультатВФайл("tmp\app.txt", "");
	КонецЕсли;

	Возврат Стр;

КонецФункции

Функция ВыбратьИзСписка(ДанныеВыбора, СписокВыбораВФайл="") Экспорт
	Возврат ЗапускПриложенияВзаимодействия("SelectValueSharp", ДанныеВыбора, 1, СписокВыбораВФайл);
КонецФункции // ВыбратьИзСписка() Экспорт

Функция ВвестиЗначение(ТекстПоУмолчанию) Экспорт
	Возврат ЗапускПриложенияВзаимодействия("inputbox", ТекстПоУмолчанию);
КонецФункции // ВвестиЗначение() Экспорт

Функция ФормаВыбораИзСписка(Данные) Экспорт

	ДанныеСписка = Данные;

	УправляемыйИнтерфейс = Новый УправляемыйИнтерфейс();
	Форма = УправляемыйИнтерфейс.СоздатьФорму();

	ПолеПоиска                              = Форма.Элементы.Добавить("ПолеПоиска", "ПолеФормы", Неопределено);
	ПолеПоиска.Вид                          = Форма.ВидПоляФормы.ПолеВвода;
	ПолеПоиска.ПоложениеЗаголовка           = Форма.ПоложениеЗаголовка.Нет;
	
	ПолеПоиска.УстановитьДействие(ЭтотОбъект, "ПриИзменении",                       "ПриИзменииПолеПоиска");

	ПолеСписка                    = Форма.Элементы.Добавить("ПолеСписка", "ПолеФормы", Неопределено);
	ПолеСписка.Вид                = Форма.ВидПоляФормы.ПолеСписка;
	ПолеСписка.ПоложениеЗаголовка = Форма.ПоложениеЗаголовка.Нет;
	ПолеСписка.СписокВыбора       = ДанныеСписка;
	ПолеСписка.Закрепление        = УправляемыйИнтерфейс.СтильЗакрепления.Заполнение;
	
	ПолеСписка.УстановитьДействие(ЭтотОбъект, "ПриВыборе", "ПриВыбореСкрипта");
	ПолеСписка.УстановитьДействие(ЭтотОбъект, "ПриДвойномКлике", "ПриВыбореСкрипта");

	Форма.Показать();
	Если ПолеСписка.Значение <> "" Тогда
		ЗавершитьРаботу(1);
	Иначе
		ЗавершитьРаботу(0);
	КонецЕсли;
КонецФункции // ФормаВыбораИзСписка(Данные, Очищать=10, СписокВыбораВФайл)

Процедура ПриВыбореСкрипта() Экспорт
	ЗапуститьПриложение(ПолеСписка.Значение,, true);
	Форма.Закрыть();
КонецПроцедуры

Процедура ПриИзменииПолеПоиска() Экспорт

	СтрПоиска = СтрЗаменить(ПолеПоиска.Значение, " ", "(.*)");

    РегВыражениеПоиск = Новый РегулярноеВыражение("(.*)(" + СтрПоиска + ")(.*)");
    РегВыражениеПоиск.ИгнорироватьРегистр = Истина;

	НовыеДанные = Новый Соответствие();

	Для каждого СтрСписка Из ДанныеСписка Цикл
		Совпадения = РегВыражениеПоиск.НайтиСовпадения(СтрСписка.Ключ);

		Если Совпадения.Количество() > 0 Тогда

			НовыеДанные.Вставить(СтрСписка.Ключ, СтрСписка.Значение);

		КонецЕсли;
	КонецЦикла;

	ПолеСписка.СписокВыбора = НовыеДанные;

КонецПроцедуры
