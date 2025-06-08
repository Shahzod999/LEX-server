interface TelegramMessage {
  message: string;
  error?: any;
  context?: string;
}

class TelegramNotifier {
  private botToken: string;
  private chatIds: number[] = [1066324870, 44197361]; // Doni, Shoha

  constructor() {
    this.botToken = process.env.TELEGRAM_TOKEN || '';
  }

  private async sendMessage(chatId: number, text: string): Promise<void> {
    if (!this.botToken) {
      console.warn('TELEGRAM_TOKEN not set, skipping notification');
      return;
    }

    try {
      const url = `https://api.telegram.org/bot${this.botToken}/sendMessage`;
      
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          chat_id: chatId,
          text: text,
          parse_mode: 'HTML'
        })
      });

      if (!response.ok) {
        console.error(`Failed to send Telegram message: ${response.status}`);
      }
    } catch (error) {
      console.error('Error sending Telegram notification:', error);
    }
  }

  public async notifyError({ message, error, context }: TelegramMessage): Promise<void> {
    const timestamp = new Date().toLocaleString('ru-RU', { timeZone: 'Asia/Tashkent' });
    
    let errorText = `🚨 <b>LEX Server Error</b>\n\n`;
    errorText += `⏰ <b>Time:</b> ${timestamp}\n`;
    errorText += `📍 <b>Context:</b> ${context || 'Unknown'}\n`;
    errorText += `💬 <b>Message:</b> ${message}\n`;
    
    if (error) {
      errorText += `\n❌ <b>Error Details:</b>\n<code>${error.message || error}</code>`;
      
      if (error.stack) {
        const stackTrace = error.stack.split('\n').slice(0, 5).join('\n');
        errorText += `\n\n📋 <b>Stack Trace:</b>\n<code>${stackTrace}</code>`;
      }
    }

    // Отправляем обоим администраторам
    for (const chatId of this.chatIds) {
      await this.sendMessage(chatId, errorText);
    }
  }

  public async notifyInfo(message: string): Promise<void> {
    const timestamp = new Date().toLocaleString('ru-RU', { timeZone: 'Asia/Tashkent' });
    const text = `ℹ️ <b>LEX Server Info</b>\n\n⏰ ${timestamp}\n💬 ${message}`;
    
    for (const chatId of this.chatIds) {
      await this.sendMessage(chatId, text);
    }
  }
}

export const telegramNotifier = new TelegramNotifier(); 