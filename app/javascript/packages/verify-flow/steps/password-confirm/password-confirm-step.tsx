import type { ChangeEvent } from 'react';
import { Accordion, PageHeading } from '@18f/identity-components';
import { t } from '@18f/identity-i18n';
import { FormStepsButton } from '@18f/identity-form-steps';
import type { FormStepComponentProps } from '@18f/identity-form-steps';
import { parse, format } from 'libphonenumber-js';
import type { VerifyFlowValues } from '../..';

interface PasswordConfirmStepProps extends FormStepComponentProps<VerifyFlowValues> {}

function getDateFormat(date: string | number | Date) {
  date = new Date(date);
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  return date.toLocaleDateString('en-US', options);
}

function PersonalInfoSummary(pii) {
  const phoneNumber = parse(`+1${pii?.phone}`);
  const formatted = format(phoneNumber, 'NATIONAL');

  return (
    <div className="padding-x-4">
      <div className="h6">{t('idv.review.full_name')}</div>
      <div className="h4 text-bold ico-absolute ico-absolute-success">
        {pii?.firstName} {pii?.lastName}
      </div>
      <div className="margin-top-4 h6">{t('idv.review.mailing_address')}</div>
      <div className="h4 text-bold ico-absolute ico-absolute-success">
        {pii?.address1} <br />
        {pii?.address2 ? pii?.address2 : ''}
        <br />
        {pii?.city && pii?.state ? `${pii?.city}, ${pii?.state} ${pii?.zipcode}` : ''}
      </div>
      <div className="margin-top-4 h6">{t('idv.review.dob')}</div>
      <div className="h4 text-bold ico-absolute ico-absolute-success">
        {getDateFormat(pii?.dob)}
      </div>
      <div className="margin-top-4 h6">{t('idv.review.ssn')}</div>
      <div className="h4 text-bold ico-absolute ico-absolute-success">{pii?.ssn}</div>
      {pii?.phone && (
        <>
          <div className="h6 margin-top-4"> {t('idv.messages.phone.phone_of_record')}</div>
          <div className="h4 text-bold ico-absolute ico-absolute-success">{formatted}</div>
        </>
      )}
    </div>
  );
}

function PasswordConfirmStep({ registerField, onChange, value }: PasswordConfirmStepProps) {
  return (
    <>
      <PageHeading>{t('idv.titles.session.review', { app_name: 'Login.gov' })}</PageHeading>
      <p>{t('idv.messages.sessions.review_message', { app_name: 'Login.gov' })}</p>
      <Accordion header={t('idv.messages.review.intro')}>
        <PersonalInfoSummary pii={value} />
      </Accordion>
      <input
        ref={registerField('password')}
        aria-label={t('idv.form.password')}
        type="password"
        onInput={(event: ChangeEvent<HTMLInputElement>) => {
          onChange({ password: event.target.value });
        }}
      />
      <FormStepsButton.Continue />
    </>
  );
}

export default PasswordConfirmStep;
