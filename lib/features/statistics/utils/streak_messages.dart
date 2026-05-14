import 'dart:math';

String getStreakMessage(int streak) {
  if (streak == 0) {
    return _getRandomMessage(_zeroDayMessages);
  } else if (streak < 7) {
    return _getRandomMessage(_smallStreakMessages);
  } else if (streak < 30) {
    return _getRandomMessage(_mediumStreakMessages);
  } else if (streak < 100) {
    return _getRandomMessage(_largeStreakMessages);
  } else {
    return _getRandomMessage(_legendaryMessages);
  }
}

String _getRandomMessage(List<String> messages) {
  final random = Random();
  return messages[random.nextInt(messages.length)];
}

const _zeroDayMessages = [
  '¡Vamos a empezar una nueva historia! 📖',
  'Hoy es un gran día para comenzar 🌅',
  'Tu viaje académico continúa, ¡manos a la obra! 💪',
  'Cada logro comienza con la decisión de empezar 🎯',
  'El momento perfecto es ahora. ¡Adelante! 🚀',
  '¡Nueva oportunidad de crecer! 🌱',
  'Tu evolución académica te espera. ¡Empieza hoy! ⭐',
];

const _smallStreakMessages = [
  '¡Buen comienzo! ¡Sigue así! 🔥',
  '¡Vas muy bien! Continúa 🏃',
  '¡Estás en racha! No pares 💫',
  '¡Genial! El momentum está contigo ⚡',
  '¡Excelente progreso! Sigue así 🎯',
  '¡Estás demostrando tu compromiso! 🌟',
  '¡Cada día cuenta! Mucho éxito 📈',
  '¡El hábito se está formando! 💪',
];

const _mediumStreakMessages = [
  '¡Impresionante! Una semana completa 🎉',
  '¡Eres consistente! Eso es la clave 🏆',
  '¡Tu disciplina brilla! Así se hace ⭐',
  '¡Una semana de oro! Sigue así 💫',
  '¡El mundo académico te respeta! 🌟',
  '¡Tu esfuerzo está dando frutos! 🍎',
  '¡Eres un ejemplo de perseverancia! 💪',
  '¡Dos semanas de dedicación! ¡Felicitaciones! 🎊',
  '¡Tu compromiso es inspirador! 🌈',
  '¡El éxito te sigue de cerca! 🏅',
];

const _largeStreakMessages = [
  '¡Un mes de brillantez académica! 👑',
  '¡Tu disciplina es legendaria! 🏆',
  '¡Eres imparable! Modo potencia total ⚡',
  '¡Un mes completo! ¡Eso es compromiso real! 🔥',
  '¡Tu consistencia es ejemplar! 🌟',
  '¡El hábito ya es tu segunda naturaleza! 💎',
  '¡Líder académico en construcción! 📚',
  '¡Un mes de transformación personal! 🌟',
  '¡Tu dedicación merece reconocimiento! 🎖️',
  '¡La excelencia te define! ⭐',
];

const _legendaryMessages = [
  '¡LEGENDARIO! ¡Más de 100 días! 👑👑👑',
  '¡Eres una fuerza de la naturaleza! 🌪️',
  '¡Tu disciplina es digna de estudio! 📖',
  '¡Eres parte del club de los imparables! 🏆',
  '¡El universo conspiró a tu favor! ✨',
  '¡Tu nombre debería estar en letras de oro! 🥇',
  '¡Inspiración pura para todos! 💫',
  '¡Gamificación máxima alcanzada! 🎮',
  '¡Eres la prueba de que todo es posible! 🌈',
  '¡Victoria tras victoria, día tras día! 🎊',
];

String getStreakEmoji(int streak) {
  if (streak == 0) return '🌱';
  if (streak < 3) return '🔥';
  if (streak < 7) return '💪';
  if (streak < 14) return '⚡';
  if (streak < 30) return '🌟';
  if (streak < 100) return '👑';
  return '🏆';
}

String getStreakTitle(int streak) {
  if (streak == 0) return 'Novato';
  if (streak < 3) return 'Iniciado';
  if (streak < 7) return 'Aprendiz';
  if (streak < 14) return 'Avanzado';
  if (streak < 30) return 'Experto';
  if (streak < 100) return 'Maestro';
  return 'Leyenda';
}
