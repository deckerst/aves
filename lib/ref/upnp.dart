import 'package:flutter/material.dart';

class Upnp {
  static const String upnpDeviceTypeMediaRenderer = 'urn:schemas-upnp-org:device:MediaRenderer:1';
  static const String upnpServiceTypeConnectionManager = 'urn:schemas-upnp-org:service:ConnectionManager:1';

  static String getProtocolInfoActionXml() {
    return '''<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
	<s:Body>
		<u:GetProtocolInfo xmlns:u="urn:schemas-upnp-org:service:ConnectionManager:1">
			<InstanceID>0</InstanceID>
		</u:GetProtocolInfo>
	</s:Body>
</s:Envelope>''';
  }
}

class UpnpProtocolInfo {
  late final Set<UpnpProtocolInfoEntry> entries;

  UpnpProtocolInfo(String text) {
    entries = text.split(',').where((v) => v.isNotEmpty).map(UpnpProtocolInfoEntry.new).toSet();
  }
}

@immutable
class UpnpProtocolInfoEntry {
  late final String protocol, network, contentFormat, additionalInfo;

  UpnpProtocolInfoEntry(String text) {
    final parts = text.split(':');
    protocol = parts[0];
    network = parts[1];
    contentFormat = parts[2];
    additionalInfo = parts[3];
  }
}
