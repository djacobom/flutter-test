import 'dart:convert';
import 'package:flutter/material.dart';

class UploadResultPage extends StatelessWidget {
  final String jsonResponse;

  const UploadResultPage({super.key, required this.jsonResponse});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> response;
    try {
      response = json.decode(jsonResponse);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Result'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error parsing response',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(jsonResponse),
              ],
            ),
          ),
        ),
      );
    }

    final status = response['status'] ?? 'unknown';
    final mode = response['mode'] ?? 'unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Result'),
        backgroundColor: status == 'success' ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(status, mode),
            const SizedBox(height: 24),
            if (status == 'success') ...[
              if (mode == 'xml')
                _buildXmlResult(response)
              else if (mode == 'gemini')
                _buildGeminiResult(response),
            ] else ...[
              _buildErrorSection(response),
            ],
            const SizedBox(height: 24),
            _buildMetadataSection(response['metadata']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status, String mode) {
    final isSuccess = status == 'success';
    return Card(
      elevation: 4,
      color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 48,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSuccess ? 'Success!' : 'Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Processing mode: ${mode.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXmlResult(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>;
    final comprobante = data['Comprobante'] as Map<String, dynamic>?;
    final emisor = data['Emisor'] as Map<String, dynamic>?;
    final receptor = data['Receptor'] as Map<String, dynamic>?;
    final conceptos = data['Conceptos'] as List<dynamic>?;
    final impuestos = data['Impuestos'] as Map<String, dynamic>?;
    final timbre = data['TimbreFiscalDigital'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comprobante Section
        if (comprobante != null) ...[
          _buildSectionTitle('Comprobante', Icons.receipt_long, Colors.blue),
          _buildInfoCard([
            _buildInfoRow('Folio', '${comprobante['Serie'] ?? ''}-${comprobante['Folio'] ?? ''}', Icons.confirmation_number),
            _buildInfoRow('Fecha', comprobante['Fecha']?.toString() ?? 'N/A', Icons.calendar_today),
            _buildInfoRow('Tipo', comprobante['TipoDeComprobante']?.toString() ?? 'N/A', Icons.category),
            _buildInfoRow('Método de Pago', comprobante['MetodoPago']?.toString() ?? 'N/A', Icons.payment),
            _buildInfoRow('Forma de Pago', comprobante['FormaPago']?.toString() ?? 'N/A', Icons.credit_card),
            _buildInfoRow('Moneda', comprobante['Moneda']?.toString() ?? 'N/A', Icons.attach_money),
          ]),
          const SizedBox(height: 16),
        ],

        // Emisor Section
        if (emisor != null) ...[
          _buildSectionTitle('Emisor', Icons.business, Colors.purple),
          _buildInfoCard([
            _buildInfoRow('RFC', emisor['Rfc']?.toString() ?? 'N/A', Icons.badge),
            _buildInfoRow('Nombre', emisor['Nombre']?.toString() ?? 'N/A', Icons.person),
            _buildInfoRow('Régimen Fiscal', emisor['RegimenFiscal']?.toString() ?? 'N/A', Icons.gavel),
          ]),
          const SizedBox(height: 16),
        ],

        // Receptor Section
        if (receptor != null) ...[
          _buildSectionTitle('Receptor', Icons.person_outline, Colors.teal),
          _buildInfoCard([
            _buildInfoRow('RFC', receptor['Rfc']?.toString() ?? 'N/A', Icons.badge),
            _buildInfoRow('Nombre', receptor['Nombre']?.toString() ?? 'N/A', Icons.person),
            _buildInfoRow('Uso CFDI', receptor['UsoCFDI']?.toString() ?? 'N/A', Icons.description),
          ]),
          const SizedBox(height: 16),
        ],

        // Conceptos Section
        if (conceptos != null && conceptos.isNotEmpty) ...[
          _buildSectionTitle('Conceptos', Icons.list_alt, Colors.orange),
          ...conceptos.map((concepto) {
            final c = concepto as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['Descripcion']?.toString() ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Cantidad', c['Cantidad']?.toString() ?? 'N/A', Icons.numbers),
                    _buildInfoRow('Valor Unitario', '\$${c['ValorUnitario']?.toString() ?? 'N/A'}', Icons.attach_money),
                    _buildInfoRow('Importe', '\$${c['Importe']?.toString() ?? 'N/A'}', Icons.price_check),
                    _buildInfoRow('Clave Prod/Serv', c['ClaveProdServ']?.toString() ?? 'N/A', Icons.qr_code),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],

        // Impuestos Section
        if (impuestos != null) ...[
          _buildSectionTitle('Impuestos', Icons.account_balance, Colors.red),
          _buildInfoCard([
            _buildInfoRow('Total Retenidos', '\$${impuestos['TotalImpuestosRetenidos']?.toString() ?? '0.00'}', Icons.remove_circle_outline),
            _buildInfoRow('Total Trasladados', '\$${impuestos['TotalImpuestosTrasladados']?.toString() ?? '0.00'}', Icons.add_circle_outline),
          ]),
          const SizedBox(height: 16),
        ],

        // Totales Section
        if (comprobante != null) ...[
          _buildSectionTitle('Totales', Icons.calculate, Colors.green),
          _buildInfoCard([
            _buildInfoRow('Subtotal', '\$${comprobante['SubTotal']?.toString() ?? 'N/A'}', Icons.money),
            if (comprobante['Descuento'] != null)
              _buildInfoRow('Descuento', '\$${comprobante['Descuento']?.toString() ?? '0.00'}', Icons.discount),
            _buildInfoRow(
              'Total',
              '\$${comprobante['Total']?.toString() ?? 'N/A'}',
              Icons.account_balance_wallet,
              isHighlight: true,
            ),
          ]),
          const SizedBox(height: 16),
        ],

        // Timbre Fiscal Section
        if (timbre != null) ...[
          _buildSectionTitle('Timbre Fiscal Digital', Icons.verified, Colors.indigo),
          _buildInfoCard([
            _buildInfoRow('UUID', timbre['UUID']?.toString() ?? 'N/A', Icons.fingerprint),
            _buildInfoRow('No. Cert. SAT', timbre['NoCertificadoSAT']?.toString() ?? 'N/A', Icons.verified_user),
          ]),
        ],
      ],
    );
  }

  Widget _buildGeminiResult(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Expense Details', Icons.receipt, Colors.blue),
        _buildInfoCard([
          _buildInfoRow('Date', data['Date']?.toString() ?? 'N/A', Icons.calendar_today),
          _buildInfoRow('Description', data['Description']?.toString() ?? 'N/A', Icons.description),
          _buildInfoRow('Payment Info', data['Payment information']?.toString() ?? 'N/A', Icons.payment),
          _buildInfoRow('Currency', data['currency']?.toString() ?? 'N/A', Icons.attach_money),
        ]),
        const SizedBox(height: 16),

        // Charges Section
        if (data['Charges'] != null) ...[
          _buildSectionTitle('Charges', Icons.list, Colors.orange),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ...(data['Charges'] as List).asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Charge ${entry.key + 1}'),
                          Text(
                            '\$${entry.value}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Total Section
        _buildSectionTitle('Total', Icons.calculate, Colors.green),
        _buildInfoCard([
          _buildInfoRow(
            'Total Amount',
            '\$${data['Total']?.toString() ?? 'N/A'}',
            Icons.account_balance_wallet,
            isHighlight: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildErrorSection(Map<String, dynamic> response) {
    final errors = response['errors'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Errors', Icons.error_outline, Colors.red),
        if (errors.isEmpty)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Processing failed with no specific error information',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...errors.map((error) {
            return Card(
              color: Colors.red.shade50,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suggestions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Make sure the file is a valid invoice or receipt\n'
                        '• Check that the file is not corrupted\n'
                        '• For XML files, ensure they are valid CFDI documents\n'
                        '• For images/PDFs, ensure they contain readable text',
                        style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(Map<String, dynamic>? metadata) {
    if (metadata == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Processing Information', Icons.info_outline, Colors.grey),
        _buildInfoCard([
          _buildInfoRow('Files Processed', metadata['file_count']?.toString() ?? 'N/A', Icons.folder),
          if (metadata['filenames'] != null)
            ...((metadata['filenames'] as List).map((filename) {
              return Padding(
                padding: const EdgeInsets.only(left: 32.0, top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filename.toString(),
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),
          if (metadata['model'] != null)
            _buildInfoRow('AI Model', metadata['model']?.toString() ?? 'N/A', Icons.psychology),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlight ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHighlight ? 18 : 15,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    color: isHighlight ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
