# Die Klasse "Payment" verwaltet eine Mitgliedschaftszahlung.
# Hierzu gehören alle normalen Mitgliedszahlungen, aber auch Fördermitgliedschaften etc.
# Nicht erfasst werden hier veranstaltungsspezifische Zahlungen.
# Diese müssen in der jeweiligen Anmeldung der Person eingetragen werden (siehe Registration). 

class Payment < ApplicationRecord
	# Versionkontrolle
	has_paper_trail

	# Zu dieser Person gehört die Zahlung
	belongs_to :person

	# Ordne Zahlungen nach der Zeit
	default_scope {order(end: :desc)}

	# Art der Mitgliedschaftszahlung:
	#  regular_member: Reguläre Mitgliedszahlung
	#  sponsor_member: Fördermitgliedschaft
	#  donation: Spende
	#  other: sonstige
	enum payment_type: {regular_member: 1, sponsor_member: 2, donation: 3, other: 4}

	validates :comment, length: {maximum: 1000}
	validates :payment_type, inclusion: {in: payment_types.keys}
	validates :start, :end, presence: true

	# Aktualisiere den Mitgliedsstatus einer Person, wenn eine Zahlung eintragen wird
	after_save :update_membership_status

	def update_membership_status
		person.compute_membership_status
		person.update_attributes({
			paid_until: person.paid_until,
			member_until: person.member_until})
	end
end
