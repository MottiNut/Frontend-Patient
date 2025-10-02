import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:frontendpatient/auth/presentation/providers/auth_provider.dart';
import 'dart:async';

class CodeVerificationScreen extends StatefulWidget {
  final String email;
  final String? phone;
  final VerificationMethod verificationMethod;

  const CodeVerificationScreen({
    Key? key,
    required this.email,
    this.phone,
    required this.verificationMethod,
  }) : super(key: key);

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  // Timer para reenvío
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  // Animaciones
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _attempts = 0;
  int _autoResendCount = 0;
  static const int _maxAutoResends = 2;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
            if (!_isLoading && !_isResending) {
              _handleCountdownExpired();
            }
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleCountdownExpired() {
    if (_autoResendCount < _maxAutoResends) {
      _autoResendCount++;
      _showSnackBar(
        'Código expirado. Enviando uno nuevo automáticamente... '
            '($_autoResendCount/$_maxAutoResends)',
        isError: false,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _resendCodeAutomatically();
      });
    } else {
      _showSnackBar(
        'Código expirado. Usa el botón "Reenviar" para solicitar uno nuevo',
        isError: true,
      );
    }
  }

  Future<void> _resendCodeAutomatically() async {
    if (_isResending) return;

    setState(() => _isResending = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.sendVerificationCode(
        method: widget.verificationMethod,
        phoneNumber: widget.verificationMethod != VerificationMethod.email
            ? widget.phone
            : null,
      );

      if (success) {
        _showSnackBar('Nuevo código enviado automáticamente', isError: false);
        _clearCode();
        _startResendTimer();
      } else {
        String errorMsg = authProvider.errorMessage ??
            'No pudimos enviar el código automáticamente';
        _showSnackBar(errorMsg, isError: true);
        _canResend = true;
      }
    } catch (e) {
      _showSnackBar(
        'Error en el reenvío automático. Usa el botón "Reenviar"',
        isError: true,
      );
      _canResend = true;
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _shakeController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get _isCodeComplete => _verificationCode.length == 6;

  Future<void> _verifyCode() async {
    if (!_isCodeComplete) {
      _showSnackBar('Completa todos los dígitos del código', isError: true);
      _shakeFields();
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final verificationResult = await authProvider.verifyCode(_verificationCode);
      bool isSuccess = verificationResult['success'] == true;
      String? message = verificationResult['message'];

      if (!isSuccess && message != null) {
        String lowerMessage = message.toLowerCase();
        if (lowerMessage.contains('verificado exitosamente') ||
            lowerMessage.contains('email verificado') ||
            lowerMessage.contains('verificado correctamente') ||
            lowerMessage.contains('verification successful')) {
          isSuccess = true;
        }
      }

      if (isSuccess) {
        _showSnackBar('¡Verificación exitosa!', isError: false);

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
                (route) => false,
            arguments: {
              'message': 'Tu cuenta ha sido verificada. ¡Ya puedes iniciar sesión!',
              'email': widget.email,
            },
          );
        }
      } else {
        _attempts++;
        if (_attempts >= 3) {
          _showSnackBar(
            'Has excedido 3 intentos. La pantalla se cerrará.',
            isError: true,
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.of(context).pop();
          });
        } else {
          String errorMessage = message ?? 'Código incorrecto. Inténtalo de nuevo';
          _showSnackBar(
            '$errorMessage\nIntento $_attempts de 3',
            isError: true,
          );
          _shakeFields();
          _clearCode();
        }
      }
    } catch (e) {
      _showSnackBar('Algo salió mal. Inténtalo de nuevo', isError: true);
      _shakeFields();
      _clearCode();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _shakeFields() {
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.sendVerificationCode(
        method: widget.verificationMethod,
        phoneNumber: widget.verificationMethod != VerificationMethod.email
            ? widget.phone
            : null,
      );

      if (success) {
        _showSnackBar('Nuevo código enviado correctamente', isError: false);
        _clearCode();
        _autoResendCount = 0;
        _startResendTimer();
      } else {
        String errorMsg = authProvider.errorMessage ?? 'No pudimos enviar el código';
        _showSnackBar(errorMsg, isError: true);
      }
    } catch (e) {
      _showSnackBar('Error al enviar el código. Inténtalo más tarde', isError: true);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (mounted && _focusNodes[0].canRequestFocus) {
      _focusNodes[0].requestFocus();
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icono animado
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mainOrange,
                            AppColors.mainOrange.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getVerificationIcon(),
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Título
              Text(
                'Verifica tu ${_getVerificationTypeText()}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                _getVerificationMessage(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Campos de código con animación
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _controllers[index].text.isNotEmpty
                                  ? AppColors.mainOrange
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            color: _controllers[index].text.isNotEmpty
                                ? AppColors.mainOrange.withOpacity(0.05)
                                : Colors.white,
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 8,
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  _focusNodes[index].unfocus();
                                  if (_isCodeComplete && !_isLoading) {
                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      _verifyCode,
                                    );
                                  }
                                }
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Botón verificar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isCodeComplete ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Verificar código',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Contador y botón reenviar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No recibiste el código? ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (_canResend)
                    GestureDetector(
                      onTap: _isResending ? null : _resendCode,
                      child: Text(
                        _isResending ? 'Enviando...' : 'Reenviar',
                        style: TextStyle(
                          color: AppColors.mainOrange,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          'Reenviar en ${_resendCountdown}s',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        if (_autoResendCount > 0)
                          Text(
                            'Auto-reenvíos: $_autoResendCount/$_maxAutoResends',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 40),

              // Consejos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mainOrange.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.mainOrange.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.mainOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Consejos útiles',
                          style: TextStyle(
                            color: AppColors.mainOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_getHelpMessage()}\n'
                          '• Los primeros $_maxAutoResends códigos se reenvían automáticamente\n'
                          '• Después puedes usar el botón "Reenviar"',
                      style: TextStyle(
                        color: AppColors.mainOrange.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVerificationIcon() {
    switch (widget.verificationMethod) {
      case VerificationMethod.email:
        return Icons.email_outlined;
      case VerificationMethod.sms:
        return Icons.sms_outlined;
      case VerificationMethod.whatsapp:
        return Icons.chat_outlined;
    }
  }

  String _getVerificationTypeText() {
    switch (widget.verificationMethod) {
      case VerificationMethod.email:
        return 'email';
      case VerificationMethod.sms:
        return 'teléfono';
      case VerificationMethod.whatsapp:
        return 'WhatsApp';
    }
  }

  String _getVerificationMessage() {
    final contact = widget.verificationMethod == VerificationMethod.email
        ? _getMaskedEmail(widget.email)
        : widget.phone ?? '';

    switch (widget.verificationMethod) {
      case VerificationMethod.email:
        return 'Te enviamos un código de 6 dígitos a\n$contact\n\n'
            'Revisa tu bandeja de entrada';
      case VerificationMethod.sms:
        return 'Te enviamos un código de 6 dígitos por SMS a\n$contact';
      case VerificationMethod.whatsapp:
        return 'Te enviamos un código de 6 dígitos por WhatsApp a\n$contact';
    }
  }

  String _getHelpMessage() {
    switch (widget.verificationMethod) {
      case VerificationMethod.email:
        return '• Revisa tu carpeta de spam o correo no deseado\n'
            '• El código es válido por 10 minutos\n'
            '• Asegúrate de tener conexión a internet';
      case VerificationMethod.sms:
        return '• Verifica que tu teléfono tenga señal\n'
            '• El código es válido por 10 minutos\n'
            '• Puede tardar unos minutos en llegar';
      case VerificationMethod.whatsapp:
        return '• Asegúrate de tener WhatsApp instalado\n'
            '• El código es válido por 10 minutos\n'
            '• Revisa los mensajes de WhatsApp Business';
    }
  }

  String _getMaskedEmail(String email) {
    if (email.isEmpty) return '';
    int visibleChars = 3;
    int atIndex = email.indexOf('@');
    if (atIndex <= visibleChars) {
      visibleChars = atIndex;
    }
    String masked = email.substring(0, visibleChars) + '*******';
    String domain = email.substring(atIndex);
    return masked + domain;
  }
}