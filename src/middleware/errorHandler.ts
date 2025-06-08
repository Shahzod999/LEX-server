import { Request, Response, NextFunction } from 'express';
import { telegramNotifier } from '../utils/telegramNotifier';

export const errorHandler = (
  error: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error caught by middleware:', error);

  // Отправляем уведомление в Telegram
  telegramNotifier.notifyError({
    message: 'Server Error Occurred',
    error: error,
    context: `${req.method} ${req.path}`
  }).catch(err => console.error('Failed to send Telegram notification:', err));

  // Возвращаем ошибку клиенту
  const statusCode = error.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    error: process.env.NODE_ENV === 'production' 
      ? 'Internal Server Error' 
      : error.message,
    timestamp: new Date().toISOString()
  });
};

// Обработчик для необработанных промисов
process.on('unhandledRejection', (reason: any) => {
  console.error('Unhandled Rejection:', reason);
  
  telegramNotifier.notifyError({
    message: 'Unhandled Promise Rejection',
    error: reason,
    context: 'Process unhandledRejection'
  }).catch(err => console.error('Failed to send Telegram notification:', err));
});

// Обработчик для необработанных исключений
process.on('uncaughtException', (error: Error) => {
  console.error('Uncaught Exception:', error);
  
  telegramNotifier.notifyError({
    message: 'Uncaught Exception',
    error: error,
    context: 'Process uncaughtException'
  }).catch(err => console.error('Failed to send Telegram notification:', err));
  
  // Graceful shutdown
  process.exit(1);
}); 