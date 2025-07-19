import 'package:logger/logger.dart';

final Logger logger = Logger(printer: PrettyPrinter());

void logDB(String msg, {Level level = Level.trace}) =>
    logger.log(level, '[DB] $msg');

void logRep(String msg, {Level level = Level.trace}) =>
    logger.log(level, '[Repository] $msg');

void logBloc(String msg, {Level level = Level.trace}) =>
    logger.log(level, '[bloc] $msg');

void logStart(String msg, {Level level = Level.trace}) =>
    logger.log(level, '[Start] $msg');

void logUI(String msg, {Level level = Level.trace}) =>
    logger.log(level, '[UI] $msg');
