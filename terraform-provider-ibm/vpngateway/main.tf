
resource "ibm_is_vpc" "testacc_vpc" {
	name = "${var.name}-vpc"
		
}
resource "ibm_is_subnet" "testacc_subnet" {
	name = "${var.name}-sub"
	vpc = "${ibm_is_vpc.testacc_vpc.id}"
	zone		   				=  "${var.region}-2"
	total_ipv4_address_count 	= 16
	
}
resource "ibm_is_vpn_gateway" "testacc_vpnGateway" {
	name = "${var.name}-gw-update"
	subnet = "${ibm_is_subnet.testacc_subnet.id}"
}
resource "ibm_is_vpn_gateway_connection" "example" {
	name          = "${var.name}-gwc"
	vpn_gateway   = ibm_is_vpn_gateway.testacc_vpnGateway.id
	peer_address  = ibm_is_vpn_gateway.testacc_vpnGateway.public_ip_address
	preshared_key = "VPNDemoPassword"
	local_cidrs   = [ibm_is_subnet.testacc_subnet.ipv4_cidr_block]
		
}
data "ibm_is_vpn_gateways" "test1" {
	
}
data "ibm_is_vpn_gateway" "example-name" {
	depends_on = [
		ibm_is_vpn_gateway_connection.example
	]
	vpn_gateway_name = ibm_is_vpn_gateway.testacc_vpnGateway.name
}